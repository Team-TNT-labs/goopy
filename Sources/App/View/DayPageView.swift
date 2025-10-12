//
//  DayPageView.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI
import SwiftData

struct DayPageView: View {
    let date: Date
    let onDateTap: () -> Void
    let onTodayTap: () -> Void
    let onColorChange: () -> Void
    let onWidgetUpdate: () -> Void
    let onArchiveTap: () -> Void
    let onToggleDarkMode: () -> Void
    let onShare: () -> Void
    @Binding var isDarkMode: Bool
    
    @Environment(\.modelContext) private var modelContext
    @State private var entry: DailyEntry?
    @State private var refreshID = UUID()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color based on dark/light mode
                (isDarkMode ? Color.darkBackground : Color.lightBackground)
                    .id(refreshID)
                
                // 모든 디바이스에서 풀스크린 레이아웃 사용
                VStack {
                    Spacer()
                        .frame(height: 100) // SafeArea 대신 상단 여백
                    
                    // Date display
                    VStack {
                        Text(DateUtils.formatMonth(date))
                            .font(.crisis(size: 40))
                            .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                        
                        Text(DateUtils.formatDay(date))
                            .font(.crisis(size: 170))
                            .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                        
                        Text(DateUtils.formatWeekday(date))
                            .font(.crisis(size: 45))
                            .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                    }
                    .onTapGesture {
                        onTodayTap()
                    }
                    
                    // Text field area (중앙 정렬)
                    NavigationLink(destination: InputView(date: date)) {
                        VStack {
                            Spacer()
                            
                            Text(entry?.content.isEmpty == false ? entry!.content : NSLocalizedString("today_thoughts_placeholder", comment: "Today's thoughts and feelings placeholder"))
                                .font(.kpubWorld(size: 21))
                                .foregroundColor(entry?.content.isEmpty == false ? (isDarkMode ? Color.darkText : Color.lightText) : (isDarkMode ? Color.darkText.opacity(0.6) : Color.lightText.opacity(0.6)))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .frame(minHeight: 200)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                        .frame(height: 120) // FloatingTabBar 공간 확보
                }
                
                // FloatingTabBar (화면 하단 고정)
                VStack {
                    Spacer()
                    FloatingTabBar(
                        isDarkMode: isDarkMode,
                        currentView: .main,
                        onToggleDarkMode: onToggleDarkMode,
                        onShare: onShare,
                        onSwitchView: onArchiveTap
                    )
                }
            }
        }
        .ignoresSafeArea(.all) // 전체 화면 색상 적용
        .onAppear {
            loadEntry()
        }
        .onChange(of: date) { _, _ in
            loadEntry()
        }
    }
    
    private func loadEntry() {
        let targetDate = DateUtils.stripToDay(date)
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate<DailyEntry> { entry in
                entry.date == targetDate
            }
        )
        
        do {
            let entries = try modelContext.fetch(descriptor)
            entry = entries.first
        } catch {
            print("Failed to fetch entry for date: \(error)")
        }
    }
}

#Preview {
    DayPageView(
        date: Date(),
        onDateTap: {},
        onTodayTap: {},
        onColorChange: {},
        onWidgetUpdate: {},
        onArchiveTap: {},
        onToggleDarkMode: {},
        onShare: {},
        isDarkMode: .constant(true)
    )
    .preferredColorScheme(.dark)
}
