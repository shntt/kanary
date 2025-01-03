//
//  LaunchAtLoginManager.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/23.
//

import ServiceManagement
import Foundation

final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()
    
    // MARK: - Properties
    private let launcherBundleId = "\(Bundle.main.bundleIdentifier!).LaunchAtLogin"
    
    var isEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserDefaultsKeys.launchAtLogin)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.launchAtLogin)
            updateLaunchAtLogin(newValue)
        }
    }
    
    // MARK: - Private Methods
    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            try SMAppService.mainApp.register()
            debugPrint("Launch at login \(enabled ? "enabled" : "disabled")")
        } catch {
            debugPrint("Failed to set launch at login: \(error.localizedDescription)")
        }
    }
}
