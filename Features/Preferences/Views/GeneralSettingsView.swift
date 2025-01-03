//
//  GeneralSettingsView.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import SwiftUI

struct GeneralSettingsView: View {
    @State private var launchAtLogin: Bool
    @Binding var isEnabled: Bool
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var updateService = UpdateService.shared
    
    init(launchAtLogin: Binding<Bool>, isEnabled: Binding<Bool>) {
        _launchAtLogin = State(initialValue: LaunchAtLoginManager.shared.isEnabled)
        _isEnabled = isEnabled
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ModernGroupBox(label: Label("基本設定", systemImage: "switch.2")) {
                    VStack(alignment: .leading, spacing: 12) {
                        ModernToggleRow(
                            title: "IME切り替えを有効にする",
                            isOn: $isEnabled,
                            onChange: { newValue in
                                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isEnabled)
                                NotificationCenter.default.post(
                                    name: .init("ToggleEnabled"),
                                    object: nil,
                                    userInfo: ["isEnabled": newValue]
                                )
                            }
                        )
                        
                        ModernToggleRow(
                            title: "ログイン時にKanaryを自動的に起動",
                            isOn: $launchAtLogin,
                            onChange: { newValue in
                                LaunchAtLoginManager.shared.isEnabled = newValue
                            }
                        )
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        ModernToggleRow(
                            title: "起動時に自動的にアップデートを確認",
                            isOn: Binding(
                                get: { settingsManager.checkUpdatesAutomatically },
                                set: { newValue in
                                    settingsManager.checkUpdatesAutomatically = newValue
                                }
                            ),
                            onChange: { _ in }
                        )
                        
                        HStack {
                            Button(action: {
                                UpdateService.shared.checkForUpdates()
                            }) {
                                Text("今すぐ確認")
                            }
                            .disabled(UpdateService.shared.isChecking)
                            
                            if UpdateService.shared.isChecking {
                                ProgressView()
                                    .scaleEffect(0.5)
                            } else if UpdateService.shared.isUpdateAvailable {
                                Button(action: {
                                    UpdateService.shared.showUpdateWindow()
                                }) {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "exclamationmark.circle.fill")
                                        Text("新しいバージョンが利用可能です")
                                    }
                                    .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 4)
                        
                        /*
                        #if DEBUG
                            Button("テスト用アップデート表示") {
                                UpdateService.shared.testUpdateAvailable()
                            }
                            .padding(.top, 8)
                        #endif
                        */
                    }
                }
                
                ModernGroupBox(label: Label("キー設定", systemImage: "keyboard")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack() {
                            ModernKeyBindingRow(
                                title: "Left",
                                action: "英数",
                                icon: "command"
                            )
                            Divider()
                            ModernKeyBindingRow(
                                title: "Right",
                                action: "かな",
                                icon: "command"
                            )
                            .padding(.leading, 4)
                        }
                        
                        Text("0.3秒以上の長押し or 複数のキーを押すと無効化されます")
                            .padding(.bottom, 0)
                            .padding(.leading, 4)
                            .foregroundColor(.secondary)
                    }
                }
                
                ModernGroupBox(label: Label("情報", systemImage: "info.circle")) {
                    VStack(alignment: .leading, spacing: 8) {
                        ModernInfoRow(label: "バージョン", value: "1.0.0")
                        ModernInfoRow(label: "ビルド", value: "2024.1")
                        
                        Divider()
                        
                        HStack {
                            Text("ソースコード")
                            Spacer()
                            Link("GitHub", destination: URL(string: "https://github.com/yourusername/Kanary")!)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
