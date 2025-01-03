//
//  IMEService.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import Foundation
import Carbon
import Cocoa

final class IMEService {
    static let shared = IMEService()
    private let settingsManager = SettingsManager.shared
    
    // MARK: - IME Control
    func toggleIME(location: IMECommand) {
        guard settingsManager.isEnabled else { return }
        
        // 現在のアプリが無効化されているかチェック
        if let frontmost = NSWorkspace.shared.frontmostApplication,
           let bundleId = frontmost.bundleIdentifier,
           settingsManager.isAppDisabled(bundleId) {
            return
        }
        
        // キーコードの設定（英数: 102, かな: 104）
        let keyCode: CGKeyCode = (location == .rightCommand) ? 104 : 102
        sendKeyEvent(keyCode)
    }
    
    // MARK: - Private Methods
    private func sendKeyEvent(_ keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        
        // キーダウンイベントを作成して送信
        if let keyDownEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true) {
            keyDownEvent.post(tap: .cghidEventTap)
        }
        
        // キーアップイベントを作成して送信
        if let keyUpEvent = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) {
            keyUpEvent.post(tap: .cghidEventTap)
        }
    }
}

// MARK: - Types
enum IMECommand {
    case leftCommand  // 英数キー
    case rightCommand // かなキー
}
