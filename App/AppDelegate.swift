//
//  AppDelegate.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/23.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties
    private var statusItem: NSStatusItem!
    private var preferencesWindow: NSWindow?
    private let eventMonitor = EventMonitorService.shared
    private let settingsManager = SettingsManager.shared
    
    #if DEBUG
    private let isDebugMode = true
    #else
    private let isDebugMode = false
    #endif
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        setupNotifications()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        debugPrint("Application launching...")
        setupInitialState()
        setupStatusItem()
        setupMenu()
        checkAccessibilityPermission()
        
        if settingsManager.shouldCheckForUpdates {
            UpdateService.shared.checkForUpdates()
            settingsManager.updateLastCheckDate()
        }
    }
    
    // MARK: - Setup Methods
    private func setupInitialState() {
        if !settingsManager.isEnabled {
            settingsManager.isEnabled = true
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleToggleEnabled(_:)),
            name: .init("ToggleEnabled"),
            object: nil
        )
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "command",
                accessibilityDescription: "Kanary"
            )
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // 有効/無効の切り替え
        let statusMenuItem = NSMenuItem(
            title: "有効",
            action: #selector(toggleEnabled(_:)),
            keyEquivalent: ""
        )
        statusMenuItem.state = settingsManager.isEnabled ? .on : .off
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 環境設定
        let preferenceItem = NSMenuItem(
            title: "環境設定...",
            action: #selector(openPreferences(_:)),
            keyEquivalent: ","
        )
        menu.addItem(preferenceItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 終了
        let quitItem = NSMenuItem(
            title: "Kanaryを終了",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    // MARK: - Accessibility
    private func checkAccessibilityPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let trusted = AXIsProcessTrusted()
            self.debugPrint("Access trusted status: \(trusted)")
            
            if !trusted {
                self.requestAccessibilityPermission()
            } else {
                self.eventMonitor.startMonitoring()
            }
        }
    }
    
    private func requestAccessibilityPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options as CFDictionary)
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if AXIsProcessTrusted() {
                    timer.invalidate()
                    self.eventMonitor.startMonitoring()
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func handleToggleEnabled(_ notification: Notification) {
        if let enabled = notification.userInfo?["isEnabled"] as? Bool {
            settingsManager.isEnabled = enabled
            debugPrint("Toggle enabled changed to: \(enabled)")
        }
    }
    
    @objc private func toggleEnabled(_ sender: NSMenuItem) {
        settingsManager.isEnabled.toggle()
        sender.state = settingsManager.isEnabled ? .on : .off
        debugPrint("Menu toggle enabled changed to: \(settingsManager.isEnabled)")
    }
    
    @objc private func openPreferences(_ sender: Any?) {
        if preferencesWindow == nil {
            let contentView = PreferencesView()
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            preferencesWindow?.backgroundColor = .clear
            preferencesWindow?.isOpaque = false
            preferencesWindow?.level = .floating
            preferencesWindow?.isMovableByWindowBackground = true
            
            let hostingView = NSHostingView(rootView: contentView)
            preferencesWindow?.contentView = hostingView
            preferencesWindow?.delegate = self
            preferencesWindow?.center()
            preferencesWindow?.setFrameAutosaveName("Preferences")
            preferencesWindow?.title = "環境設定"
            preferencesWindow?.isReleasedWhenClosed = false
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // MARK: - Debug
    private func debugPrint(_ message: String) {
        if isDebugMode {
            print("Kanary Debug:", message)
        }
    }
}

// MARK: - NSWindowDelegate
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           window === preferencesWindow {
            preferencesWindow = nil
        }
    }
}
