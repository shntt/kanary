//
//  ModernGroupBox.swift
//  Kanary
//
//  Created by Shinto Takahashi on 2024/10/24.
//

import SwiftUI

struct ModernGroupBox<Content: View, L: View>: View {
    let label: L
    let content: Content
    
    init(label: L, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    // 従来の Label<Text, Image> を使用する場合のイニシャライザ
    init(label: Label<Text, Image>, @ViewBuilder content: () -> Content) where L == Label<Text, Image> {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            label
                .font(.headline)
                .foregroundColor(.primary)
            
            content
                .padding()
                .background(
                    ZStack {
                        VisualEffectBackground()
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.windowBackgroundColor).opacity(0.3))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
}
