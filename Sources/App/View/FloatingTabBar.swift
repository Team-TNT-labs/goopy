//
//  FloatingTabBar.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI

struct FloatingTabBar: View {
    let isDarkMode: Bool
    let currentView: ViewType
    let onToggleDarkMode: () -> Void
    let onShare: () -> Void
    let onSwitchView: () -> Void
    @State private var isPressed = false
    
    enum ViewType {
        case main
        case archive
    }
    
    var body: some View {
        HStack(spacing: 40) {
            // 다크/라이트 모드 토글 버튼
            Button(action: onToggleDarkMode) {
                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 30))
                    .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
            }
            
            // 타원형 시간 버튼 (뷰 전환)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
                onSwitchView()
            }) {
                Text(currentView == .main ? "DAY" : "MONTH")
                    .font(.crisis(size: 20))
                    .foregroundColor(isDarkMode ? Color.darkBackground : Color.lightBackground)
                    .frame(width: currentView == .main ? 150 : 150, height: 32)
                    .background(
                        Ellipse()
                            .fill(isDarkMode ? Color.darkText : Color.lightText)
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentView)
            }
            
            // 공유 버튼
            Button(action: onShare) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 30))
                    .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .padding(.bottom, 50) // SafeArea 고려 + 20pt 위로
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    VStack {
        Spacer()
        FloatingTabBar(
            isDarkMode: true,
            currentView: .main,
            onToggleDarkMode: {},
            onShare: {},
            onSwitchView: {}
        )
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}

