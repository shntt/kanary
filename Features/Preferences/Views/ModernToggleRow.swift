//
//  ModernToggleRow.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import SwiftUI

struct ModernToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let onChange: (Bool) -> Void
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { isOn },
            set: { newValue in
                isOn = newValue
                onChange(newValue)
            }
        )) {
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ModernKeyBindingRow: View {
    let title: String
    let action: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.secondary)
                .padding(.trailing, 4)
            
            Text(title)
                .frame(alignment: .leading)
                .padding(.trailing, 16)
            
            Image(systemName: "arrow.right")
                .foregroundColor(.secondary)
                .imageScale(.small)
                .padding(.trailing, 16)
            
            Text(action)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ModernInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct ModernAppToggleRow: View {
    let app: AppInfo
    @ObservedObject var settings: ApplicationSettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .fontWeight(.medium)
                
                Text(app.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { !settings.disabledApps.contains(app.bundleIdentifier) },
                set: { enabled in
                    if enabled {
                        settings.disabledApps.remove(app.bundleIdentifier)
                    } else {
                        settings.disabledApps.insert(app.bundleIdentifier)
                    }
                }
            ))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Group {
                if isHovered {
                    VisualEffectBackground()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}
