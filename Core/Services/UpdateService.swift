//
//  UpdateService.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/25.
//

import Foundation
import Combine
import Cocoa
import SwiftUI

final class UpdateService: NSObject, ObservableObject {
    static let shared = UpdateService()
    
    @Published private(set) var latestVersion: Release?
    @Published private(set) var isChecking = false
    @Published private(set) var error: Error?
    
    private let settingsManager = SettingsManager.shared
    private let currentVersion: Version
    private var cancellables = Set<AnyCancellable>()
    private var updateWindowController: NSWindowController?
    
    private override init() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        self.currentVersion = Version(string: version) ?? Version(major: 1, minor: 0, patch: 0)
        super.init()
    }
    
    func checkForUpdates() {
        guard !isChecking else { return }
        isChecking = true
        error = nil
        
        let url = URL(string: "https://api.github.com/repos/shntt/Kanary/releases/latest")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Release.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isChecking = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] release in
                self?.latestVersion = release
                self?.notifyIfUpdateAvailable(release)
            }
            .store(in: &cancellables)
    }
    
    private func notifyIfUpdateAvailable(_ release: Release) {
        guard let latestVersion = Version(string: release.tagName.replacingOccurrences(of: "v", with: "")),
              latestVersion > currentVersion else {
            return
        }
        
        let notification = NSUserNotification()
        notification.title = "アップデートが利用可能です"
        notification.informativeText = "Kanary \(release.tagName)が利用可能です。"
        notification.actionButtonTitle = "詳細を表示"
        
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    var isUpdateAvailable: Bool {
        guard let latestVersion = latestVersion,
              let version = Version(string: latestVersion.tagName.replacingOccurrences(of: "v", with: "")) else {
            return false
        }
        return version > currentVersion
    }
    
    func showUpdateWindow() {
        guard let latestVersion = self.latestVersion else { return }
        
        let contentView = UpdateView(
            release: latestVersion,
            currentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "不明",
            onCancel: { [weak self] in
                self?.closeUpdateWindow()
            }
        )
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "アップデート"
        window.contentView = NSHostingView(rootView: contentView)
        window.center()
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        
        let windowController = NSWindowController(window: window)
        self.updateWindowController = windowController
        
        windowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func closeUpdateWindow() {
        updateWindowController?.close()
        updateWindowController = nil
    }
    
    // テスト用メソッド
    func testUpdateAvailable() {
        let mockRelease = Release(
            tagName: "v2.0.0",
            name: "Kanary 2.0.0",
            body: """
            # 更新内容
            
            ## 新機能
            - 機能A: より快適な操作が可能になりました
            - 機能B: 新しい設定オプションを追加
            
            ## 改善
            - パフォーマンスの向上
            - メモリ使用量の最適化
            
            ## バグ修正
            - 特定の条件下でクラッシュする問題を修正
            - 設定が正しく保存されない問題を修正
            """,
            htmlUrl: "https://github.com/shntt/Kanary/releases/tag/v2.0.0",
            assets: [
                Release.Asset(
                    name: "Kanary.dmg",
                    browserDownloadUrl: "https://github.com/shntt/Kanary/releases/download/v2.0.0/Kanary.dmg"
                )
            ]
        )
        self.latestVersion = mockRelease
        
        DispatchQueue.main.async { [weak self] in
            self?.showUpdateWindow()
        }
    }
}

extension UpdateService: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                              didActivate notification: NSUserNotification) {
        if notification.activationType == .actionButtonClicked {
            DispatchQueue.main.async { [weak self] in
                self?.showUpdateWindow()
            }
        }
    }
}
