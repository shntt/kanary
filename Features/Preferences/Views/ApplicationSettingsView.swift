//
//  ApplicationSettingsView.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/23.
//

import SwiftUI

struct ApplicationSettingsView: View {
    @StateObject private var settings = ApplicationSettingsViewModel()
    @State private var searchText = ""
    
    var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return settings.allApps
        }
        return settings.allApps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("アプリケーションを検索...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(
                ZStack {
                    VisualEffectBackground()
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.windowBackgroundColor).opacity(0.3))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding()
            
            // アプリ一覧
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filteredApps) { app in
                        ModernAppToggleRow(app: app, settings: settings)
                    }
                }
                .padding(.horizontal)
            }
            
            // ステータスバー
            HStack {
                Text("\(settings.allApps.count) 個のアプリケーション")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Spacer()
                
                Button(action: { settings.updateAllApps() }) {
                    Label("更新", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.separatorColor).opacity(0.1))
        }
        .background(VisualEffectBackground())
        .onAppear {
            settings.updateAllApps()
        }
    }
}
