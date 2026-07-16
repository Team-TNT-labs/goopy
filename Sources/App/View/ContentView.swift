//
//  ContentView.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI
import SwiftData
import WidgetKit
import UIKit

// 색상 확장
extension Color {
    // 다크/라이트 모드 색상
    static let lightBackground = Color(red: 0.65, green: 0.83, blue: 0.98) // A7D3F9
    static let lightText = Color.black
    static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05) // 더 어두운 색상
    static let darkText = Color(red: 0.65, green: 0.83, blue: 0.98) // A7D3F9

    // 기존 색상 배열 (호환성을 위해 유지)
    static let pageColors: [Color] = [
        Color(red: 0.18, green: 0.21, blue: 0.22), // 기본 어두운 회색
        Color(red: 0.25, green: 0.15, blue: 0.25), // 보라색
        Color(red: 0.15, green: 0.25, blue: 0.35), // 파란색
        Color(red: 0.15, green: 0.35, blue: 0.25), // 초록색
        Color(red: 0.35, green: 0.25, blue: 0.15), // 주황색
        Color(red: 0.35, green: 0.15, blue: 0.15), // 빨간색
        Color(red: 0.25, green: 0.25, blue: 0.15)  // 노란색
    ]
}

enum ViewType {
    case main
    case archive
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    // 저장 키는 기존과 동일. bool(forKey:) 미설정 기본값(false)과 맞춰 라이트 모드가 기본.
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var currentView: ViewType = .main
    @State private var currentDate: Date = DateUtils.today()

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background based on dark/light mode
                (isDarkMode ? Color.darkBackground : Color.lightBackground)

                VStack(spacing: 0) {

                    // Main content based on current view
                    if currentView == .main {
                        MainView(
                            currentDate: $currentDate,
                            onTodayTap: {
                                currentDate = DateUtils.today()
                            },
                            onArchiveTap: {
                                withAnimation(.none) {
                                    currentView = .archive
                                }
                            },
                            onToggleDarkMode: { toggleDarkMode() },
                            onShare: { shareEntry() },
                            isDarkMode: $isDarkMode
                        )
                    } else {
                        ArchiveView(
                            onDateTap: {
                                withAnimation(.none) {
                                    currentView = .main
                                }
                            },
                            onDateSelect: { date in
                                currentDate = date
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentView = .main
                                }
                            },
                            onToggleDarkMode: { toggleDarkMode() },
                            onShare: { shareEntry() },
                            isDarkMode: isDarkMode
                        )
                    }
                }
            }
            .ignoresSafeArea(.all) // 전체 화면 색상 적용
            .navigationBarHidden(true)
            .onAppear {
                updateWidgetData()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func toggleDarkMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
        }
        updateWidgetData()
    }

    private func shareEntry() {
        // 공유 시점의 최신 데이터를 조회한다 (stale 캐시 금지)
        let entryContent = fetchEntry(for: currentDate)?.content ?? ""
        let shareText = entryContent.isEmpty
            ? NSLocalizedString("today_thoughts_placeholder", comment: "Today's thoughts and feelings placeholder")
            : entryContent
        let dateString = DateUtils.formatDate(currentDate)

        var activityItems: [Any] = ["\(dateString)\n\n\(shareText)"]
        if let shareImage = captureShareView(content: entryContent) {
            activityItems.append(shareImage)
        }

        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let root = window.rootViewController {
            root.present(activityVC, animated: true)
        }
    }

    private func captureShareView(content: String) -> UIImage? {
        // 공유용 정사각형 뷰 생성
        let shareView = ShareView(
            date: currentDate,
            content: content,
            isDarkMode: isDarkMode
        )

        // SwiftUI 뷰를 UIImage로 변환
        let renderer = ImageRenderer(content: shareView)
        renderer.scale = UIScreen.main.scale

        // 정사각형 크기 설정
        let size = CGSize(width: 400, height: 400)
        renderer.proposedSize = .init(width: size.width, height: size.height)

        return renderer.uiImage
    }

    private func fetchEntry(for date: Date) -> DailyEntry? {
        let targetDate = DateUtils.stripToDay(date)
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate<DailyEntry> { entry in
                entry.date == targetDate
            }
        )

        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Failed to fetch entry for date: \(error)")
            return nil
        }
    }

    private func updateWidgetData() {
        let todayEntry = fetchEntry(for: DateUtils.today())
        WidgetDataStore.sync(
            content: todayEntry?.content ?? "",
            colorIndex: todayEntry?.colorIndex ?? 0,
            isDarkMode: isDarkMode
        )
    }
}

struct MainView: View {
    @Binding var currentDate: Date
    let onTodayTap: () -> Void
    let onArchiveTap: () -> Void
    let onToggleDarkMode: () -> Void
    let onShare: () -> Void
    @Binding var isDarkMode: Bool

    // 성능 최적화를 위한 범위 축소
    private let dayRange = -365...365 // 총 730일 (약 2년)

    var body: some View {
        TabView(selection: $currentDate) {
            ForEach(dayRange, id: \.self) { dayOffset in
                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: DateUtils.today()) ?? DateUtils.today()

                DayPageView(
                    date: date,
                    onTodayTap: onTodayTap,
                    onArchiveTap: onArchiveTap,
                    onToggleDarkMode: onToggleDarkMode,
                    onShare: onShare,
                    isDarkMode: $isDarkMode
                )
                .tag(date)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: currentDate) // 더 부드러운 애니메이션
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
