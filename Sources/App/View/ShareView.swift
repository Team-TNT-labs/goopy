//
//  ShareView.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI

struct ShareView: View {
    let date: Date
    let content: String
    let isDarkMode: Bool
    
    var body: some View {
        ZStack {
            // 배경색
            (isDarkMode ? Color.darkBackground : Color.lightBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 여백
                
                // 날짜 표시 영역
                VStack(spacing: 8) {
                    Text(DateUtils.formatMonth(date))
                        .font(.crisis(size: 22))
                        .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                    
                    Text(DateUtils.formatDay(date))
                        .font(.crisis(size: 75))
                        .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                    
                    Text(DateUtils.formatWeekday(date))
                        .font(.crisis(size: 24))
                        .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                }
                .padding(40)
                
                Spacer()
                
                // 일기 내용 영역
                VStack {
                    if content.isEmpty {
                        Text(NSLocalizedString("today_thoughts_placeholder", comment: "Today's thoughts and feelings placeholder"))
                            .font(.kpubWorld(size: 18))
                            .foregroundColor((isDarkMode ? Color.darkText : Color.lightText).opacity(0.6))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    } else {
                        Text(content)
                            .font(.kpubWorld(size: 17))
                            .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 40)
                .frame(maxHeight: .infinity)
                
                // 하단 여백
                Spacer()
                Text("GOOPY")
                    .font(.crisis(size: 18))
                    .foregroundColor(isDarkMode ? Color.darkBackground : Color.lightBackground)
                    .background(
                        Ellipse()
                            .fill(isDarkMode ? Color.darkText : Color.lightText)
                    )
                    .padding(40)
            }
        }
        .frame(width: 400, height: 500) // 정사각형 크기
    }
}

#Preview {
    ShareView(
        date: Date(),
        content: "오늘은 정말 좋은 하루였어요. 새로운 도전을 시작했고, 많은 것을 배웠습니다.",
        isDarkMode: true
    )
}
