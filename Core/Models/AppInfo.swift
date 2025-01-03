//
//  AppInfo.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import Cocoa

struct AppInfo: Identifiable, Hashable {
    let bundleIdentifier: String
    let name: String
    let icon: NSImage?
    
    var id: String { bundleIdentifier }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleIdentifier)
    }
    
    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}
