//
//  UpdateWindow.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/25.
//

import SwiftUI

@MainActor
class UpdateViewModel: ObservableObject {
    let release: Release
    let currentVersion: String
    let onCancel: () -> Void
    
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var errorMessage: String?
    
    private let downloadManager = DownloadManager()
    
    init(release: Release, currentVersion: String, onCancel: @escaping () -> Void) {
        self.release = release
        self.currentVersion = currentVersion
        self.onCancel = onCancel
    }
    
    func downloadAndInstall() {
        Task {
            do {
                isDownloading = true
                try await downloadManager.downloadAndMount(from: release)
                // DMGが正常にマウントされたら、Finderで開く
                NSWorkspace.shared.open(URL(fileURLWithPath: "/Volumes/Kanary"))
                onCancel() // ウィンドウを閉じる
            } catch {
                self.errorMessage = error.localizedDescription
            }
            isDownloading = false
        }
    }
    
    func dismissError() {
        errorMessage = nil
    }
}

struct UpdateView: View {
    @StateObject private var viewModel: UpdateViewModel
    
    init(release: Release,
         currentVersion: String,
         onCancel: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: UpdateViewModel(
            release: release,
            currentVersion: currentVersion,
            onCancel: onCancel
        ))
    }
    
    var body: some View {
        ZStack {
            VisualEffectBackground()
            
            VStack(spacing: 20) {
                ModernGroupBox(label: Label("アップデート情報", systemImage: "arrow.down.circle.fill")) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("新しいバージョンが利用可能です")
                                .font(.headline)
                        }
                        
                        HStack {
                            Text("現在のバージョン: \(viewModel.currentVersion)")
                            Spacer()
                            Text("→")
                            Spacer()
                            Text("新しいバージョン: \(viewModel.release.tagName)")
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                ModernGroupBox(label: HStack {
                    Label("更新内容", systemImage: "doc.text")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Link(destination: URL(string: viewModel.release.htmlUrl)!) {
                        HStack(spacing: 4) {
                            Text("GitHubで確認")
                                .font(.subheadline)
                            Image(systemName: "arrow.up.right.square")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                    }
                }) {
                    ScrollView {
                        Text(viewModel.release.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 150)
                }
                
                HStack {
                    Button("後で") {
                        viewModel.onCancel()
                    }
                    .keyboardShortcut(.cancelAction)
                    .disabled(viewModel.isDownloading)
                    
                    Spacer()
                    
                    if viewModel.isDownloading {
                        ProgressView("ダウンロード中...", value: viewModel.downloadProgress)
                            .frame(width: 150)
                    } else {
                        Button("今すぐアップデート") {
                            viewModel.downloadAndInstall()
                        }
                        .keyboardShortcut(.defaultAction)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .alert("エラー", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
