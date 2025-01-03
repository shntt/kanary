//
//  KanaryApp.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/23.
//

import SwiftUI

@main
struct KanaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
