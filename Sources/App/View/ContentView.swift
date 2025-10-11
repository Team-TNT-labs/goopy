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

// 폰트 확장
extension Font {
    static func crisis(size: CGFloat) -> Font {
        return Font.custom("ClimateCrisisKR-1990", size: size)
    }
    
    static func kpubWorld(size: CGFloat) -> Font {
        return Font.custom("KoPubWorldBatang_Pro Medium", size: size)
    }
    
    static func neurimboGothic(size: CGFloat) -> Font {
        return Font.custom("neurimboGothicRegular", size: size)
    }
}

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
    @State private var todayEntry: DailyEntry?
    @State private var showingArchive = false
    @State private var content: String = ""
    @State private var currentView: ViewType = .main
    @State private var currentDate: Date = DateUtils.today()
    @State private var refreshBackground = UUID()
    @State private var isDarkMode: Bool = true // 다크 모드 기본값
    @State private var selectedDate: Date? = nil // 아카이브에서 선택된 날짜
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background based on dark/light mode
                (isDarkMode ? Color.darkBackground : Color.lightBackground)
                    .id(refreshBackground)
                
                VStack(spacing: 0) {
                    
                    // Main content based on current view
                    if currentView == .main {
                        MainView(
                            todayEntry: todayEntry,
                            content: $content,
                            currentDate: $currentDate,
                            onDateTap: { currentView = .archive },
                            onTodayTap: {
                                currentDate = DateUtils.today()
                                loadEntryForDate(DateUtils.today())
                            },
                            onDateChange: { newDate in
                                currentDate = newDate
                                loadEntryForDate(newDate)
                            },
                            onColorChange: {
                                DispatchQueue.main.async {
                                    self.refreshBackground = UUID()
                                    self.loadTodayEntry()
                                    self.updateWidgetData()
                                }
                            },
                            onWidgetUpdate: {
                                updateWidgetData()
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
                                selectedDate = date
                                currentDate = date
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentView = .main
                                }
                                loadEntryForDate(date)
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
                // 저장된 다크모드 설정 불러오기
                isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
                loadTodayEntry()
                updateWidgetData()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func toggleDarkMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
        }
        // persist toggle and refresh widget/background
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        refreshBackground = UUID()
        updateWidgetData()
    }

    private func shareEntry() {
        // 정사각형 공유 이미지 생성
        if let shareImage = captureShareView() {
            let dateString = DateUtils.formatDate(currentDate)
            let text = todayEntry?.content ?? NSLocalizedString("today_thoughts_placeholder", comment: "Today's thoughts and feelings placeholder")
            
            let activityVC = UIActivityViewController(
                activityItems: [
                    "\(dateString)\n\n\(text)",
                    shareImage
                ],
                applicationActivities: nil
            )
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let root = window.rootViewController {
                root.present(activityVC, animated: true)
            }
        } else {
            // 이미지 생성 실패 시 기존 텍스트 공유
            let text = todayEntry?.content ?? NSLocalizedString("today_thoughts_placeholder", comment: "Today's thoughts and feelings placeholder")
            let dateString = DateUtils.formatDate(currentDate)
            let activityVC = UIActivityViewController(
                activityItems: ["\(dateString)\n\n\(text)"],
                applicationActivities: nil
            )
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let root = window.rootViewController {
                root.present(activityVC, animated: true)
            }
        }
    }
    
    private func captureShareView() -> UIImage? {
        // 공유용 정사각형 뷰 생성
        let shareView = ShareView(
            date: currentDate,
            content: todayEntry?.content ?? "",
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

    private func loadTodayEntry() {
        loadEntryForDate(DateUtils.today())
    }
    
    private func loadEntryForDate(_ date: Date) {
        let targetDate = DateUtils.stripToDay(date)
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate<DailyEntry> { entry in
                entry.date == targetDate
            }
        )
        
        do {
            let entries = try modelContext.fetch(descriptor)
            todayEntry = entries.first
            content = todayEntry?.content ?? ""
        } catch {
            print("Failed to fetch entry for date: \(error)")
        }
    }
    
    private func updateWidgetData() {
        // UserDefaults를 통해 위젯에 데이터 전달
        guard let userDefaults = UserDefaults(suiteName: "group.com.goopy") else {
            print("Failed to access App Group UserDefaults")
            return
        }
        
        let content = todayEntry?.content ?? ""
        let colorIndex = max(0, min(6, todayEntry?.colorIndex ?? 0))
        
        userDefaults.set(content, forKey: "todayContent")
        userDefaults.set(colorIndex, forKey: "todayColorIndex")
        userDefaults.set(isDarkMode, forKey: "isDarkMode")
        userDefaults.synchronize()
        
        print("Widget data updated: content='\(content)', colorIndex=\(colorIndex), isDarkMode=\(isDarkMode)")
        
        // 위젯 새로고침 요청
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}

struct MainView: View {
    let todayEntry: DailyEntry?
    @Binding var content: String
    @Binding var currentDate: Date
    let onDateTap: () -> Void
    let onTodayTap: () -> Void
    let onDateChange: (Date) -> Void
    let onColorChange: () -> Void
    let onWidgetUpdate: () -> Void
    let onArchiveTap: () -> Void
    let onToggleDarkMode: () -> Void
    let onShare: () -> Void
    @Binding var isDarkMode: Bool
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView(selection: $currentDate) {
            ForEach(-3650...3650, id: \.self) { dayOffset in
                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: DateUtils.today()) ?? DateUtils.today()
                
                DayPageView(
                    date: date,
                    onDateTap: onDateTap,
                    onTodayTap: onTodayTap,
                    onColorChange: onColorChange,
                    onWidgetUpdate: onWidgetUpdate,
                    onArchiveTap: onArchiveTap,
                    onToggleDarkMode: onToggleDarkMode,
                    onShare: onShare,
                    isDarkMode: $isDarkMode
                )
                .tag(date)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: currentDate) { _, newDate in
            onDateChange(newDate)
        }
    }
}

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
        ZStack {
            // Background color based on dark/light mode
            (isDarkMode ? Color.darkBackground : Color.lightBackground)
                .id(refreshID)
            
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
    ContentView()
        .preferredColorScheme(.dark)
}
