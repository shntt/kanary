//
//  DownloadManager.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/25.
//

import Foundation

class DownloadManager: ObservableObject {
    @Published var downloadProgress: Double = 0
    @Published var isDownloading = false
    @Published var error: Error?
    
    enum DownloadError: LocalizedError {
        case dmgNotFound
        case downloadFailed
        case mountFailed
        
        var errorDescription: String? {
            switch self {
            case .dmgNotFound:
                return "DMGファイルが見つかりませんでした"
            case .downloadFailed:
                return "ダウンロードに失敗しました"
            case .mountFailed:
                return "DMGファイルを開けませんでした"
            }
        }
    }
    
    func downloadAndMount(from release: Release) async throws {
        guard let dmgAsset = release.assets.first(where: { $0.name.hasSuffix(".dmg") }),
              let downloadURL = URL(string: dmgAsset.browserDownloadUrl) else {
            throw DownloadError.dmgNotFound
        }
        
        await MainActor.run {
            isDownloading = true
            downloadProgress = 0
            error = nil
        }
        
        let session = URLSession.shared
        let (localURL, response) = try await session.download(
            from: downloadURL,
            delegate: DownloadDelegate { [weak self] progress in
                Task { @MainActor in
                    self?.downloadProgress = progress
                }
            }
        )
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DownloadError.downloadFailed
        }
        
        // DMGをマウント
        try await mountDMG(at: localURL)
        
        await MainActor.run {
            isDownloading = false
        }
    }
    
    private func mountDMG(at url: URL) async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
        process.arguments = ["attach", url.path]
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw DownloadError.mountFailed
        }
    }
}

// URLSessionDownloadDelegate
class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let progressHandler: (Double) -> Void
    
    init(progressHandler: @escaping (Double) -> Void) {
        self.progressHandler = progressHandler
        super.init()
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler(progress)
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // デリゲートメソッド
    }
}
