//
//  ApplicationSettingsViewModel.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import SwiftUI
import UniformTypeIdentifiers

final class ApplicationSettingsViewModel: ObservableObject {
    @Published var allApps: [AppInfo] = []
    @Published var disabledApps: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(disabledApps), forKey: "disabledApps")
        }
    }
    
    init() {
        let savedApps = UserDefaults.standard.stringArray(forKey: "disabledApps") ?? []
        disabledApps = Set(savedApps)
        updateAllApps()
    }
    
    func updateAllApps() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var apps: [AppInfo] = []
            
            // 実行中のアプリケーションを取得
            let runningApps = NSWorkspace.shared.runningApplications
            for app in runningApps {
                if let bundleId = app.bundleIdentifier,
                   let appName = app.localizedName,
                   self?.shouldIncludeApp(bundleId: bundleId,
                                        activationPolicy: app.activationPolicy) == true {
                    let icon: NSImage
                    if let appIcon = app.icon {
                        icon = appIcon
                    } else {
                        icon = NSWorkspace.shared.icon(for: UTType.application)
                    }
                    
                    let appInfo = AppInfo(
                        bundleIdentifier: bundleId,
                        name: appName,
                        icon: icon
                    )
                    apps.append(appInfo)
                }
            }
            
            // Applicationsフォルダのアプリを取得
            if let applicationsURL = FileManager.default.urls(
                for: .applicationDirectory,
                in: .localDomainMask
            ).first {
                self?.getApps(from: applicationsURL, into: &apps)
            }
            
            // ユーザーのApplicationsフォルダのアプリを取得
            if let userAppsURL = FileManager.default.urls(
                for: .applicationDirectory,
                in: .userDomainMask
            ).first {
                self?.getApps(from: userAppsURL, into: &apps)
            }
            
            // System Applicationsフォルダのアプリを取得
            if let systemAppsURL = URL(string: "/System/Applications") {
                self?.getApps(from: systemAppsURL, into: &apps)
            }
            
            // 重複を削除し、名前でソート
            let uniqueApps = Array(Set(apps)).sorted { $0.name < $1.name }
            
            DispatchQueue.main.async {
                self?.allApps = uniqueApps
            }
        }
    }
    
    private func shouldIncludeApp(bundleId: String, activationPolicy: NSApplication.ActivationPolicy = .regular) -> Bool {
        // バックグラウンドエージェントや特定のシステムプロセスを除外
        let excludedPrefixes = [
            "com.apple.CoreServices.",
            "com.apple.InputMethod.",
            "com.apple.SecurityAgent",
            // ... 他の除外プレフィックス
        ]
        
        let excludedKeywords = [
            "com.apple.SecurityAgent",
            // "agent",
            // "helper",
            // "service",
            // ... 他の除外キーワード
        ]
        
        let includedBundleIds = [
            "com.apple.Terminal",
            "com.apple.Console",
            // ... 常に含めるアプリ
        ]
        
        if includedBundleIds.contains(bundleId) {
            return true
        }
        
        if activationPolicy == .prohibited {
            return false
        }
        
        for prefix in excludedPrefixes {
            if bundleId.hasPrefix(prefix) {
                return false
            }
        }
        
        let lowercaseBundleId = bundleId.lowercased()
        for keyword in excludedKeywords {
            if lowercaseBundleId.contains(keyword.lowercased()) {
                return false
            }
        }
        
        return bundleId.count >= 10
    }
    
    private func getApps(from directory: URL, into apps: inout [AppInfo]) {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return }
        
        for case let url as URL in enumerator {
            guard url.pathExtension == "app" else { continue }
            
            if let bundle = Bundle(url: url),
               let bundleId = bundle.bundleIdentifier,
               let appName = bundle.infoDictionary?["CFBundleName"] as? String,
               shouldIncludeApp(bundleId: bundleId) {
                
                let workspace = NSWorkspace.shared
                let icon = workspace.icon(forFile: url.path)
                
                let appInfo = AppInfo(
                    bundleIdentifier: bundleId,
                    name: appName,
                    icon: icon
                )
                
                apps.append(appInfo)
            }
        }
    }
}
