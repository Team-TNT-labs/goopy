//
//  ArchiveView.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI
import SwiftData


struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyEntry.date, order: .reverse)
    private var allEntries: [DailyEntry]
    @State private var selectedMonth: Date = Date()
    @State private var calendarMonth: Date = Date()
    let onDateTap: () -> Void
    let onDateSelect: (Date) -> Void
    let onToggleDarkMode: () -> Void
    let onShare: () -> Void
    let isDarkMode: Bool
    
    // 선택된 월의 글들만 필터링
    private var filteredEntries: [DailyEntry] {
        let calendar = Calendar.current
        let selectedYear = calendar.component(.year, from: selectedMonth)
        let selectedMonthComponent = calendar.component(.month, from: selectedMonth)
        
        return allEntries.filter { entry in
            let entryYear = calendar.component(.year, from: entry.date)
            let entryMonth = calendar.component(.month, from: entry.date)
            return entryYear == selectedYear && entryMonth == selectedMonthComponent
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // 캘린더 뷰 (고정)
                    ScrollableCalendarView(
                        isDarkMode: isDarkMode,
                        onMonthChanged: { month in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                calendarMonth = month
                                selectedMonth = month
                            }
                        },
                        onDateTap: onDateSelect
                    )
                    .padding(.horizontal, geometry.size.width > 700 ? 10 : 20)
                    .padding(.top, 60)
                    .padding(.bottom, geometry.size.width > 700 ? 10 : -30) // iPhone에서 캘린더를 더 위로
                    .frame(maxHeight: geometry.size.width > 700 ? 500 : 350) // 캘린더 컨테이너 최대 높이 제한
                    
                    // 디바이더
                    Divider()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    // 일기 목록 (스크롤)
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if filteredEntries.isEmpty {
                                // 해당 월에 글이 없을 때
                                VStack(spacing: 16) {
                                    Text(NSLocalizedString("no_entries_this_month", comment: "No entries written this month"))
                                        .font(.kpubWorld(size: 21))
                                        .foregroundColor((isDarkMode ? Color.darkText : Color.lightText).opacity(0.6))
                                        .padding(.top, 40)
                                }
                            } else {
                                ForEach(filteredEntries, id: \.id) { entry in
                                    ArchiveEntryRow(entry: entry, onDateTap: onDateTap, onDateSelect: onDateSelect, isDarkMode: isDarkMode)
                                        .padding(.horizontal, geometry.size.width > 700 ? 10 : 16)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding(.top, geometry.size.width > 700 ? 10 : 10) // 디바이더와 일기 목록 사이 간격
                        .padding(.bottom, 120) // FloatingTabBar 공간 확보
                    }
                    Spacer()
                }
                .background(isDarkMode ? Color.darkBackground : Color.lightBackground)
                // FloatingTabBar
                VStack {
                    Spacer()
                    FloatingTabBar(
                        isDarkMode: isDarkMode,
                        currentView: .archive,
                        onToggleDarkMode: onToggleDarkMode,
                        onShare: onShare,
                        onSwitchView: onDateTap
                    )
                }
            }
        }
    }
}

struct ArchiveEntryRow: View {
    let entry: DailyEntry
    let onDateTap: () -> Void
    let onDateSelect: (Date) -> Void
    let isDarkMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date and content
            VStack(alignment: .leading, spacing: 12) {
                // Date and weekday
                HStack {
                    Text(DateUtils.formatDay(entry.date))
                        .font(.crisis(size: 24))
                        .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                    
                    Text(DateUtils.formatWeekday(entry.date))
                        .font(.crisis(size: 24))
                        .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                    
                    Spacer()
                }
                .onTapGesture {
                    onDateSelect(entry.date)
                }
                
                // Content
                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.kpubWorld(size: 18))
                        .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(20)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyEntry.self, configurations: config)
    
    ArchiveView(
        onDateTap: {},
        onDateSelect: { _ in },
        onToggleDarkMode: {},
        onShare: {},
        isDarkMode: true
    )
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyEntry.self, configurations: config)
    
    ArchiveView(
        onDateTap: {},
        onDateSelect: { _ in },
        onToggleDarkMode: {},
        onShare: {},
        isDarkMode: false
    )
    .modelContainer(container)
    .preferredColorScheme(.light)
}
