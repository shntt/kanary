//
//  PreferencesViewModel.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import SwiftUI

final class PreferencesViewModel: ObservableObject {
    @Published private(set) var contentHeight: CGFloat = 400
    private let settingsManager = SettingsManager.shared
    
    // MARK: - Public Properties
    var isEnabled: Bool {
        get { settingsManager.isEnabled }
        set { settingsManager.isEnabled = newValue }
    }
    
    var launchAtLogin: Bool {
        get { settingsManager.launchAtLogin }
        set { settingsManager.launchAtLogin = newValue }
    }
    
    // MARK: - Content Height Management
    func updateContentHeight(_ height: CGFloat) {
        let adjustedHeight = height + 150 // タブバーの高さを加算
        
        if abs(contentHeight - adjustedHeight) > 10 {
            withAnimation(.easeInOut(duration: 0.2)) {
                contentHeight = adjustedHeight
            }
        } else {
            contentHeight = adjustedHeight
        }
    }
}
