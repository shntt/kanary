//
//  EventMonitorService.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import Cocoa

final class EventMonitorService {
    static let shared = EventMonitorService()
    
    // MARK: - Properties
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let imeService = IMEService.shared
    private let eventTapCallback: CGEventTapCallBack
    
    // Commandキー押下状態
    private var isCommandKeyPressed = false
    private var otherModifiersPressed = false
    
    // 短押し・長押し判定用
    private var lastCommandKeyDown: TimeInterval = 0
    
    // ダブルプレス関連
    private var lastCommandReleaseTime: TimeInterval = 0
    private let doublePressThreshold: TimeInterval = 0.3
    
    // ★ 追加: 2回押し(ダブルプレス)が確定したら true
    private var isDoublePress = false
    
    // IME切り替えを実行するための遅延実行タイマー
    private var toggleScheduled = false
    private var scheduledToggleTimer: DispatchWorkItem?
    
    // デバッグ用
    private var lastFlags: CGEventFlags = []
    
    // MARK: - Initialization
    init() {
        eventTapCallback = { proxy, type, event, userInfo in
            guard let userInfo = userInfo else {
                return Unmanaged.passRetained(event)
            }
            let service = Unmanaged<EventMonitorService>
                .fromOpaque(userInfo)
                .takeUnretainedValue()
            
            return service.handleEvent(
                proxy: proxy,
                type: CGEventType(rawValue: type.rawValue)!,
                event: event
            )
        }
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        setupEventTap()
    }
    
    // MARK: - Private Methods
    private func setupEventTap() {
        let eventMask = CGEventMask(
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << CGEventType.keyDown.rawValue)
        )
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: eventTapCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            debugPrint("Failed to create event tap")
            return
        }
        
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        
        if let runLoopSource = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }
    
    private func handleEvent(proxy: CGEventTapProxy,
                             type: CGEventType,
                             event: CGEvent) -> Unmanaged<CGEvent>? {
        
        if type == .flagsChanged {
            handleFlagsChanged(event)
        }
        else if type == .keyDown && isCommandKeyPressed {
            // Command+他キー (例: Command + C/Vなど) が押された
            otherModifiersPressed = true
        }
        
        return Unmanaged.passRetained(event)
    }
    
    private func handleFlagsChanged(_ event: CGEvent) {
        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let isCommandDown = flags.contains(.maskCommand)
        
        let hasOtherModifiers = flags.contains(.maskShift) ||
            flags.contains(.maskControl) ||
            flags.contains(.maskAlternate) ||
            flags.contains(.maskSecondaryFn)
        
        // 右Command: 54, 左Command: 55 (環境によって異なる場合あり)
        let commandLocation = (keyCode == 54) ? IMECommand.rightCommand : IMECommand.leftCommand
        
        if isCommandDown && !isCommandKeyPressed {
            // ========== Command を押し始めたタイミング ==========
            isCommandKeyPressed = true
            otherModifiersPressed = hasOtherModifiers
            
            let now = Date().timeIntervalSince1970
            
            // 既にタイマーが動いていればキャンセル
            if let timer = scheduledToggleTimer {
                timer.cancel()
                scheduledToggleTimer = nil
                toggleScheduled = false
            }
            
            // ★ 連続押下判定
            if (now - lastCommandReleaseTime) < doublePressThreshold {
                // 0.3秒以内に再度押された → ダブルプレスと見なす
                debugPrint("Detected double press => Apple Intelligence priority. IME toggling canceled.")
                
                // ダブルプレスフラグを立てる
                isDoublePress = true
            } else {
                isDoublePress = false
            }
            
            // 短押し用に記録
            lastCommandKeyDown = now
            
        }
        else if !isCommandDown && isCommandKeyPressed {
            // ========== Command を離したタイミング ==========
            let currentTime = Date().timeIntervalSince1970
            let elapsed = currentTime - lastCommandKeyDown
            
            isCommandKeyPressed = false
            lastCommandReleaseTime = currentTime
            
            // (A) ダブルプレスが発生していれば IME 切り替えをスキップ
            if isDoublePress {
                debugPrint("Second press => skip scheduling IME toggle.")
                // ダブルプレスフラグをリセット
                isDoublePress = false
                return
            }
            
            // (B) 短押し判定: elapsed < 0.3、他修飾キーなしの場合 => IMEをスケジュール
            if elapsed < 0.3 && !otherModifiersPressed {
                scheduleToggleIME(location: commandLocation)
            } else {
                debugPrint("Long press or other modifiers => skip IME toggle.")
            }
            
        }
        else if isCommandDown && hasOtherModifiers && !otherModifiersPressed {
            // Commandが押されてる最中に他修飾キーが入った
            otherModifiersPressed = true
        }
        
        lastFlags = flags
    }
    
    /// IME切り替えを0.3秒後に実行する仕組み
    private func scheduleToggleIME(location: IMECommand) {
        toggleScheduled = true
        
        scheduledToggleTimer?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // 0.3秒後の時点でダブルプレスが入っていなければ実行
            self.debugPrint("No second press detected within 0.3s => Toggling IME now.")
            self.imeService.toggleIME(location: location)
            
            self.toggleScheduled = false
            self.scheduledToggleTimer = nil
        }
        
        scheduledToggleTimer = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + doublePressThreshold, execute: workItem)
    }
    
    private func debugPrint(_ msg: String) {
        #if DEBUG
        print("[EventMonitorService]", msg)
        #endif
    }
}
