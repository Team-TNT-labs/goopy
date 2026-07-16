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
    let onTodayTap: () -> Void
    let onArchiveTap: () -> Void
    let onToggleDarkMode: () -> Void
    let onShare: () -> Void
    @Binding var isDarkMode: Bool

    // SwiftData를 단일 진실 원천으로 사용한다.
    // InputView에서 저장/수정하면 저장 시점과 무관하게 이 뷰가 자동 갱신된다
    // (onAppear 시점 수동 fetch는 InputView의 onDisappear 저장보다 먼저 실행되어 stale했음).
    @Query private var entries: [DailyEntry]

    private var entry: DailyEntry? { entries.first }

    init(
        date: Date,
        onTodayTap: @escaping () -> Void,
        onArchiveTap: @escaping () -> Void,
        onToggleDarkMode: @escaping () -> Void,
        onShare: @escaping () -> Void,
        isDarkMode: Binding<Bool>
    ) {
        self.date = date
        self.onTodayTap = onTodayTap
        self.onArchiveTap = onArchiveTap
        self.onToggleDarkMode = onToggleDarkMode
        self.onShare = onShare
        self._isDarkMode = isDarkMode

        let targetDate = DateUtils.stripToDay(date)
        _entries = Query(filter: #Predicate<DailyEntry> { entry in
            entry.date == targetDate
        })
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color based on dark/light mode
                (isDarkMode ? Color.darkBackground : Color.lightBackground)

                // 모든 디바이스에서 풀스크린 레이아웃 사용
                VStack {
                    Spacer()
                        .frame(height: 100) // SafeArea 대신 상단 여백

                    // Date display
                    VStack {
                        Text(DateUtils.formatMonth(date))
                            .font(.crisis(size: UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.width <= 375 ? 32 : 36))
                            .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)

                        Text(DateUtils.formatDay(date))
                            .font(.crisis(size: UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.width <= 375 ? 120 : 150))
                            .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)

                        Text(DateUtils.formatWeekday(date))
                            .font(.crisis(size: UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.bounds.width <= 375 ? 36 : 40))
                            .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                    }
                    .onTapGesture {
                        onTodayTap()
                    }

                    // Text field area (중앙 정렬)
                    NavigationLink(destination: InputView(date: date)) {
                        VStack {
                            Spacer()

                            Text(displayContent)
                                .font(.kpubWorld(size: 21))
                                .foregroundColor(hasContent ? (isDarkMode ? Color.darkText : Color.lightText) : (isDarkMode ? Color.darkText.opacity(0.6) : Color.lightText.opacity(0.6)))
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
    }

    private var hasContent: Bool {
        entry?.content.isEmpty == false
    }

    private var displayContent: String {
        if let content = entry?.content, !content.isEmpty {
            return content
        }
        return NSLocalizedString("today_thoughts_placeholder", comment: "Today's thoughts and feelings placeholder")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyEntry.self, configurations: config)

    DayPageView(
        date: Date(),
        onTodayTap: {},
        onArchiveTap: {},
        onToggleDarkMode: {},
        onShare: {},
        isDarkMode: .constant(true)
    )
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
