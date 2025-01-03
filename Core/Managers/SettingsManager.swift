//
//  SettingsManager.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import SwiftUI

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    // MARK: - Published Properties
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: UserDefaultsKeys.isEnabled)
        }
    }
    
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: UserDefaultsKeys.launchAtLogin)
        }
    }
    
    @Published var checkUpdatesAutomatically: Bool {
        didSet {
            UserDefaults.standard.set(checkUpdatesAutomatically, forKey: "checkUpdatesAutomatically")
        }
    }
    
    // MARK: - Private Properties
    private var lastUpdateCheck: Date {
        get {
            UserDefaults.standard.object(forKey: "lastUpdateCheck") as? Date ?? Date(timeIntervalSince1970: 0)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastUpdateCheck")
        }
    }
    
    private let disabledAppsKey = "disabledApps"
    private var disabledApps: Set<String> {
        get {
            Set(UserDefaults.standard.stringArray(forKey: disabledAppsKey) ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: disabledAppsKey)
        }
    }
    
    // MARK: - Initialization
    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isEnabled)
        self.launchAtLogin = UserDefaults.standard.bool(forKey: UserDefaultsKeys.launchAtLogin)
        self.checkUpdatesAutomatically = UserDefaults.standard.bool(forKey: "checkUpdatesAutomatically")
        
        // デフォルト値の設定
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            self.isEnabled = true
            self.launchAtLogin = false
            self.checkUpdatesAutomatically = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    // MARK: - Public Methods
    func isAppDisabled(_ bundleId: String) -> Bool {
        disabledApps.contains(bundleId)
    }
    
    func setAppDisabled(_ disabled: Bool, for bundleId: String) {
        if disabled {
            disabledApps.insert(bundleId)
        } else {
            disabledApps.remove(bundleId)
        }
    }
    
    var shouldCheckForUpdates: Bool {
        guard checkUpdatesAutomatically else { return false }
        return Date().timeIntervalSince(lastUpdateCheck) > 86400
    }
    
    func updateLastCheckDate() {
        lastUpdateCheck = Date()
    }
}
