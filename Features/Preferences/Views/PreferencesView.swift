//
//  PreferencesView.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/23.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @AppStorage(UserDefaultsKeys.isEnabled) private var isEnabled = true
    @AppStorage(UserDefaultsKeys.launchAtLogin) private var launchAtLogin = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VisualEffectBackground()
            
            TabView {
                GeneralSettingsView(
                    launchAtLogin: $launchAtLogin,
                    isEnabled: $isEnabled
                )
                .tabItem {
                    Label("一般", systemImage: "gear")
                }
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ContentHeightPreferenceKey.self,
                            value: geometry.frame(in: .local).height
                        )
                    }
                )
                
                ApplicationSettingsView()
                    .tabItem {
                        Label("アプリケーション", systemImage: "app.badge")
                    }
            }
        }
        .frame(width: 500, height: viewModel.contentHeight, alignment: .bottom)
        .onPreferenceChange(ContentHeightPreferenceKey.self) { height in
            viewModel.updateContentHeight(height)
        }
    }
}

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 400
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
