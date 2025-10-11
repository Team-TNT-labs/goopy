//
//  CalendarView.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI

struct ScrollableCalendarView: View {
    let isDarkMode: Bool
    @State private var currentMonthIndex: Int = 12 // 현재 월을 중앙에 위치 (0-based index)
    let onMonthChanged: ((Date) -> Void)?
    let onDateTap: ((Date) -> Void)?
    
    // 월 인덱스를 실제 날짜로 변환하는 헬퍼 함수
    private func monthFromIndex(_ index: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        
        // 현재 월의 첫째 날을 기준으로 계산
        let currentMonth = calendar.dateInterval(of: .month, for: today)?.start ?? today
        return calendar.date(byAdding: .month, value: index - 12, to: currentMonth) ?? today
    }
    
    private var currentMonth: Date {
        return monthFromIndex(currentMonthIndex)
    }
    
    var body: some View {
        TabView(selection: $currentMonthIndex) {
            ForEach(0...24, id: \.self) { monthIndex in
                let month = monthFromIndex(monthIndex)
                
                VStack(spacing: 8) {
                    // 월 표시
                    Text(formatMonth(month))
                        .font(.crisis(size: 24))
                        .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                        .padding(.bottom, 8)
                    
                    // 캘린더 그리드
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                        // 요일 헤더
                        ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                            let headerColor = (isDarkMode ? Color.darkText : Color.lightText).opacity(0.7)
                            Text(day)
                                .font(.crisis(size: 14))
                                .foregroundColor(headerColor)
                                .frame(height: 32)
                        }
                        
                        // 날짜들
                        ForEach(calendarDays(for: month), id: \.self) { day in
                            if day == 0 {
                                // 빈 칸
                                Text("")
                                    .frame(height: 24)
                            } else {
                                ScrollableCalendarDayView(day: day, month: month, isDarkMode: isDarkMode, onDateTap: onDateTap)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(monthIndex)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: 300) // 명시적 높이 설정
        .onChange(of: currentMonthIndex) { oldValue, newValue in
            // TabView의 기본 스와이프 제스처가 작동한 후 콜백 호출
            if oldValue != newValue {
                let newMonth = monthFromIndex(newValue)
                onMonthChanged?(newMonth)
            }
        }
    }
    
    // 특정 월의 캘린더 데이터 생성
    private func calendarDays(for month: Date) -> [Int] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: month)
        let monthComponent = calendar.component(.month, from: month)
        
        // 해당 월의 첫 번째 날
        let firstDay = DateComponents(year: year, month: monthComponent, day: 1)
        let firstDate = calendar.date(from: firstDay)!
        
        // 첫 번째 날의 요일 (0=일요일, 1=월요일, ...)
        let firstWeekday = calendar.component(.weekday, from: firstDate) - 1
        
        // 해당 월의 일수
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDate)!.count
        
        var days: [Int] = []
        
        // 첫 주의 빈 칸들
        for _ in 0..<firstWeekday {
            days.append(0)
        }
        
        // 실제 날짜들
        for day in 1...daysInMonth {
            days.append(day)
        }
        
        return days
    }
    
    // 월 포맷팅
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date).uppercased()
    }
}

struct ScrollableCalendarDayView: View {
    let day: Int
    let month: Date
    let isDarkMode: Bool
    let onDateTap: ((Date) -> Void)?
    
    var body: some View {
        let isTodayDay = isToday(day, month: month)
        let textColor = isTodayDay ? 
            (isDarkMode ? Color.darkBackground : Color.lightBackground) : 
            (isDarkMode ? Color.darkText : Color.lightText)
        let backgroundColor = isTodayDay ? 
            (isDarkMode ? Color.darkText : Color.lightText) : 
            Color.clear
        let borderColor = isTodayDay ? 
            (isDarkMode ? Color.darkText : Color.lightText) : 
            Color.clear
        
        Text("\(day)")
            .font(.crisis(size: 16))
            .foregroundColor(textColor)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(backgroundColor)
            )
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: isTodayDay ? 2 : 0)
            )
            .onTapGesture {
                let calendar = Calendar.current
                let year = calendar.component(.year, from: month)
                let monthComponent = calendar.component(.month, from: month)
                
                // 단순하고 강력한 날짜 생성
                let selectedDate = calendar.date(from: DateComponents(year: year, month: monthComponent, day: day)) ?? Date()
                onDateTap?(selectedDate)
            }
    }
    
    // 오늘인지 확인
    private func isToday(_ day: Int, month: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: month)
        let currentYear = calendar.component(.year, from: month)
        let todayMonth = calendar.component(.month, from: today)
        let todayYear = calendar.component(.year, from: today)
        let todayDay = calendar.component(.day, from: today)
        
        return currentYear == todayYear && currentMonth == todayMonth && day == todayDay
    }
}

struct CalendarView: View {
    let isDarkMode: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // 월 표시
            Text(formatMonth(Date()))
                .font(.crisis(size: 24))
                .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                .padding(.bottom, 4)
            
            // 캘린더 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                // 요일 헤더
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                    let headerColor = (isDarkMode ? Color.darkText : Color.lightText).opacity(0.7)
                    Text(day)
                        .font(.crisis(size: 14))
                        .foregroundColor(headerColor)
                        .frame(height: 32)
                }
                
                // 날짜들
                ForEach(calendarDays, id: \.self) { day in
                    if day == 0 {
                        // 빈 칸
                        Text("")
                            .frame(height: 32)
                    } else {
                        CalendarDayView(day: day, isDarkMode: isDarkMode)
                    }
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
    
    // 현재 월의 캘린더 데이터 생성
    private var calendarDays: [Int] {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        // 해당 월의 첫 번째 날
        let firstDay = DateComponents(year: year, month: month, day: 1)
        let firstDate = calendar.date(from: firstDay)!
        
        // 첫 번째 날의 요일 (0=일요일, 1=월요일, ...)
        let firstWeekday = calendar.component(.weekday, from: firstDate) - 1
        
        // 해당 월의 일수
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstDate)!.count
        
        var days: [Int] = []
        
        // 첫 주의 빈 칸들
        for _ in 0..<firstWeekday {
            days.append(0)
        }
        
        // 실제 날짜들
        for day in 1...daysInMonth {
            days.append(day)
        }
        
        return days
    }
    
    // 월 포맷팅
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date).uppercased()
    }
}

struct CalendarDayView: View {
    let day: Int
    let isDarkMode: Bool
    
    var body: some View {
        let isTodayDay = isToday(day)
        let textColor = isTodayDay ? 
            (isDarkMode ? Color.darkBackground : Color.lightBackground) : 
            (isDarkMode ? Color.darkText : Color.lightText)
        let backgroundColor = isTodayDay ? 
            (isDarkMode ? Color.darkText : Color.lightText) : 
            Color.clear
        let borderColor = isTodayDay ? 
            (isDarkMode ? Color.darkText : Color.lightText) : 
            Color.clear
        
        Text("\(day)")
            .font(.crisis(size: 16))
            .foregroundColor(textColor)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(backgroundColor)
            )
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: isTodayDay ? 2 : 0)
            )
    }
    
    // 오늘인지 확인
    private func isToday(_ day: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.component(.day, from: today) == day
    }
}

#Preview {
    ScrollableCalendarView(
        isDarkMode: true, 
        onMonthChanged: { month in
            print("Month changed to: \(month)")
        },
        onDateTap: { date in
            print("Date tapped: \(date)")
        }
    )
        .preferredColorScheme(.dark)
}

