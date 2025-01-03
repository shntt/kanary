//
//  UserDefaultsKeys.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/23.
//

import SwiftUI

struct UserDefaultsKeys {
    // MARK: - Keys
    /// IME切り替え機能の有効/無効状態を保存するキー
    static let isEnabled = "isEnabled"
    
    /// 起動時の自動起動設定を保存するキー
    static let launchAtLogin = "launchAtLogin"
    
    // MARK: - Suite
    /// UserDefaultsのスイートネーム（アプリのバンドルIDを使用）
    static let suiteName = Bundle.main.bundleIdentifier
    
    // MARK: - Shared Instance
    /// 共通のUserDefaultsインスタンス
    static let shared = UserDefaults.standard
    
    // MARK: - Convenience Methods
    static func bool(forKey key: String) -> Bool {
        shared.bool(forKey: key)
    }
    
    static func set(_ value: Bool, forKey key: String) {
        shared.set(value, forKey: key)
        shared.synchronize()
    }
    
    /// UserDefaultsの初期化
    static func registerDefaults() {
        let defaults: [String: Any] = [
            isEnabled: true,
            launchAtLogin: false
        ]
        shared.register(defaults: defaults)
    }
    
    // MARK: - Private Init
    private init() {}
}
