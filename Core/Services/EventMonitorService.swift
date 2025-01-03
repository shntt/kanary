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
    
    private var lastCommandKeyDown: TimeInterval = 0
    private var isCommandKeyPressed = false
    private var otherModifiersPressed = false
    private var lastFlags: CGEventFlags = []
    
    // MARK: - Initialization
    init() {
        // イベントコールバックの初期化
        eventTapCallback = { proxy, type, event, userInfo in
            guard let userInfo = userInfo else { return Unmanaged.passRetained(event) }
            
            let service = Unmanaged<EventMonitorService>
                .fromOpaque(userInfo)
                .takeUnretainedValue()
            
            return service.handleEvent(
                proxy: proxy,
                type: CGEventType(rawValue: type.rawValue)!,
                event: event)
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
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .flagsChanged {
            handleFlagsChanged(event)
        } else if type == .keyDown && isCommandKeyPressed {
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
        
        let commandLocation = keyCode == 54 ? IMECommand.rightCommand : IMECommand.leftCommand
        
        if isCommandDown && !isCommandKeyPressed {
            if hasOtherModifiers {
                otherModifiersPressed = true
            }
            isCommandKeyPressed = true
            otherModifiersPressed = hasOtherModifiers
            lastCommandKeyDown = Date().timeIntervalSince1970
        } else if !isCommandDown && isCommandKeyPressed {
            let currentTime = Date().timeIntervalSince1970
            let elapsed = currentTime - lastCommandKeyDown
            
            if elapsed < 0.3 && !otherModifiersPressed {
                imeService.toggleIME(location: commandLocation)
            }
            isCommandKeyPressed = false
        } else if isCommandDown && hasOtherModifiers && !otherModifiersPressed {
            otherModifiersPressed = true
        }
        
        lastFlags = flags
    }
}
