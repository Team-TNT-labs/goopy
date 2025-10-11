import WidgetKit
import SwiftUI

// Custom Font Extension for Widget
extension Font {
    static func crisis(size: CGFloat) -> Font {
        return .custom("ClimateCrisisKR-1990", size: size)
    }
    
    static func kpubWorld(size: CGFloat) -> Font {
        return .custom("KoPubWorldBatang_Pro Medium", size: size)
    }
    
    static func neurimboGothic(size: CGFloat) -> Font {
        return .custom("neurimboGothicRegular", size: size)
    }
}

// Color Extension for Widget
extension Color {
    // 다크/라이트 모드 색상
    static let lightBackground = Color(red: 0.65, green: 0.83, blue: 0.98) // A7D3F9
    static let lightText = Color.black
    static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.05) // 더 어두운 색상
    static let darkText = Color(red: 0.65, green: 0.83, blue: 0.98) // A7D3F9
}

enum WidgetMode: Int, CaseIterable {
    case text = 0
    case calendar = 1
    case dateOnly = 2
    
    var displayName: String {
        switch self {
        case .text: return "텍스트"
        case .calendar: return "캘린더"
        case .dateOnly: return "날짜만"
        }
    }
}

struct Provider: TimelineProvider {
    let widgetMode: WidgetMode
    
    init(mode: WidgetMode) {
        self.widgetMode = mode
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), content: "오늘의 생각을 남겨보세요", colorIndex: 0, widgetMode: widgetMode, isDarkMode: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadTodayEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = loadTodayEntry()
        let currentDate = Date()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadTodayEntry() -> SimpleEntry {
        // 앱과 데이터 공유를 위한 UserDefaults
        guard let userDefaults = UserDefaults(suiteName: "group.com.goopy") else {
            return SimpleEntry(date: Date(), content: "오늘의 생각을 남겨보세요", colorIndex: 0, widgetMode: widgetMode, isDarkMode: true)
        }
        
        let content = userDefaults.string(forKey: "todayContent") ?? "오늘의 생각을 남겨보세요"
        let colorIndex = max(0, min(6, userDefaults.integer(forKey: "todayColorIndex")))
        let isDarkMode = userDefaults.bool(forKey: "isDarkMode")
        
        return SimpleEntry(date: Date(), content: content, colorIndex: colorIndex, widgetMode: widgetMode, isDarkMode: isDarkMode)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let content: String
    let colorIndex: Int
    let widgetMode: WidgetMode
    let isDarkMode: Bool
}

struct goopyWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    // 색상 배열 (앱과 동일)
    private let pageColors: [Color] = [
        Color(red: 0.18, green: 0.21, blue: 0.22), // 기본 다크 그레이
        Color(red: 0.25, green: 0.15, blue: 0.25), // 보라색
        Color(red: 0.15, green: 0.25, blue: 0.35), // 파란색
        Color(red: 0.15, green: 0.35, blue: 0.25), // 초록색
        Color(red: 0.35, green: 0.25, blue: 0.15), // 주황색
        Color(red: 0.35, green: 0.15, blue: 0.15), // 빨간색
        Color(red: 0.25, green: 0.25, blue: 0.15)  // 노란색
    ]

    var body: some View {
        ZStack {
            switch family {
            case .systemSmall:
                smallWidgetView
            case .systemMedium:
                mediumWidgetView
            default:
                smallWidgetView
            }
        }
        .containerBackground(for: .widget) {
            // 다크/라이트 모드에 따른 배경 색상
            entry.isDarkMode ? Color.darkBackground : Color.lightBackground
        }
    }
    
    private var smallWidgetView: some View {
        VStack {
            switch entry.widgetMode {
            case .text:
                // 텍스트 모드: 일기 내용 표시
                Text(entry.content.isEmpty ? "오늘의 생각을\n남겨보세요" : entry.content)
                    .font(.kpubWorld(size: 13))
                    .foregroundColor(entry.content.isEmpty ? (entry.isDarkMode ? Color.darkText.opacity(0.6) : Color.lightText.opacity(0.6)) : (entry.isDarkMode ? Color.darkText : Color.lightText))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 12)
            case .calendar:
                // 캘린더 모드: 현재 월의 캘린더 표시
                calendarView
            case .dateOnly:
                // 날짜만 모드: 미디움 위젯의 왼쪽 영역과 동일
                dateOnlyView
            }
        }
        .padding(8)
    }
    
    // 날짜만 표시하는 뷰 (미디움 위젯의 왼쪽 영역과 동일)
    private var dateOnlyView: some View {
        VStack(alignment: .center, spacing: 2) {
            // 요일 (가장 위)
            Text(formatWeekday(entry.date))
                .font(.crisis(size: 16))
                .foregroundColor(entry.isDarkMode ? Color.darkText : Color.lightText)
            
            // 일 (가장 크게)
            Text(formatDay(entry.date))
                .font(.crisis(size: 64))
                .foregroundColor(entry.isDarkMode ? Color.darkText : Color.lightText)
            
            // 월
            Text(formatMonth(entry.date))
                .font(.crisis(size: 16))
                .foregroundColor(entry.isDarkMode ? Color.darkText : Color.lightText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var mediumWidgetView: some View {
        HStack(spacing: 16) {
            // 왼쪽: 날짜 영역 (요일, 월, 일 세로 배치)
            VStack(alignment: .center, spacing: 0) {
                // 월
            Text(formatMonth(entry.date))
                .font(.crisis(size: 18))
                .foregroundColor(entry.isDarkMode ? Color.darkText : Color.lightText)
                // 일 (가장 크게)
                Text(formatDay(entry.date))
                    .font(.crisis(size: 45))
                    .foregroundColor(entry.isDarkMode ? Color.darkText : Color.lightText)
                // 요일 (가장 위)
                Text(formatWeekday(entry.date))
                    .font(.crisis(size: 18))
                    .foregroundColor(entry.isDarkMode ? Color.darkText : Color.lightText)
                
            }
            .frame(width: 100)
            
            // 오른쪽: 일기 내용
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.content.isEmpty ? "오늘의 생각을 남겨보세요" : entry.content)
                    .font(.kpubWorld(size: 13))
                    .foregroundColor(entry.content.isEmpty ? (entry.isDarkMode ? Color.darkText.opacity(0.6) : Color.lightText.opacity(0.6)) : (entry.isDarkMode ? Color.darkText : Color.lightText))
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                
            }
            .frame(width: 200)
        }
        .padding(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale(identifier: "en_US")
        let dateString = formatter.string(from: date).uppercased()
        
        // 오늘인지 확인
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "TODAY • \(dateString)"
        } else {
            return dateString
        }
    }
    
    private func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date).uppercased()
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date).uppercased()
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // 캘린더 뷰 구현
    private var calendarView: some View {
        VStack(spacing: 4) {
            Spacer()
            // 월 표시
            Text(formatMonth(entry.date))
                .font(.crisis(size: 14))
                .foregroundColor(entry.isDarkMode ? Color.darkText : Color.lightText)
                .padding(.bottom, 2)
            
            // 캘린더 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7), spacing: 1) {
                // 요일 헤더
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.crisis(size: 7))
                        .foregroundColor((entry.isDarkMode ? Color.darkText : Color.lightText).opacity(0.7))
                        .frame(height: 16)
                }
                
                // 날짜들
                ForEach(calendarDays, id: \.self) { day in
                    if day == 0 {
                        // 빈 칸
                        Text("")
                            .frame(height: 16)
                    } else {
                        Text("\(day)")
                            .font(.crisis(size: 6))
                            .foregroundColor(isToday(day) ? (entry.isDarkMode ? Color.darkBackground : Color.lightBackground) : (entry.isDarkMode ? Color.darkText : Color.lightText))
                            .frame(width: 15, height: 15)
                            .background(
                                Circle()
                                    .fill(isToday(day) ? (entry.isDarkMode ? Color.darkText : Color.lightText) : Color.clear)
                            )
                    }
                }
            }
        }
    }
    
    // 현재 월의 캘린더 데이터 생성
    private var calendarDays: [Int] {
        let calendar = Calendar.current
        let now = entry.date
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        // 해당 월의 첫 번째 날
        guard let firstDay = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return []
        }
        
        // 첫 번째 날의 요일 (0=일요일, 1=월요일, ...)
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        // 해당 월의 일수
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDay)?.count ?? 0
        
        var days: [Int] = []
        
        // 첫 주의 빈 칸들
        for _ in 0..<firstWeekday {
            days.append(0)
        }
        
        // 실제 날짜들
        for day in 1...daysInMonth {
            days.append(day)
        }
        
        // 6주로 맞추기 위해 빈 칸 추가 (최대 42개)
        while days.count < 42 {
            days.append(0)
        }
        
        return days
    }
    
    // 오늘 날짜인지 확인
    private func isToday(_ day: Int) -> Bool {
        let calendar = Calendar.current
        let now = entry.date
        let today = calendar.component(.day, from: now)
        return day == today
    }
}

// 텍스트 위젯
struct goopyTextWidget: Widget {
    let kind: String = "goopyTextWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(mode: .text)) { entry in
            goopyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Goopy Diary (텍스트)")
        .description("오늘의 일기를 텍스트로 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// 캘린더 위젯
struct goopyCalendarWidget: Widget {
    let kind: String = "goopyCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(mode: .calendar)) { entry in
            goopyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Goopy Diary (캘린더)")
        .description("오늘의 일기와 캘린더를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// 날짜만 위젯
struct goopyDateOnlyWidget: Widget {
    let kind: String = "goopyDateOnlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(mode: .dateOnly)) { entry in
            goopyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Goopy Diary (날짜만)")
        .description("오늘 날짜를 확인하세요.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct goopyWidgetBundle: WidgetBundle {
    var body: some Widget {
        goopyTextWidget()
        goopyCalendarWidget()
        goopyDateOnlyWidget()
    }
}

#Preview(as: .systemSmall) {
    goopyTextWidget()
} timeline: {
    SimpleEntry(date: .now, content: "오늘은 정말 좋은 하루였어요dddddddddddddddddddddddddddddddddd!", colorIndex: 2, widgetMode: .text, isDarkMode: true)
    SimpleEntry(date: .now, content: "새로운 도전을 시작했어요", colorIndex: 4, widgetMode: .calendar, isDarkMode: false)
    SimpleEntry(date: .now, content: "", colorIndex: 0, widgetMode: .dateOnly, isDarkMode: true)
}
