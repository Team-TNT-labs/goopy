//
//  InputView.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct InputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    @State private var existingEntry: DailyEntry?
    @FocusState private var isTextFieldFocused: Bool
    @State private var isDarkMode: Bool = true
    
    let date: Date
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Text editor
                TextEditor(text: $content)
                    .font(.kpubWorld(size: 19))
                    .foregroundColor(isDarkMode ? Color.darkText : Color.lightText)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 24)
                    .focused($isTextFieldFocused)
                
                Spacer()
            }
            .background(isDarkMode ? Color.darkBackground : Color.lightBackground)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // 저장된 다크모드 설정 불러오기
            isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            loadExistingEntry()
            // 키보드 자동 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
        .onDisappear {
            saveEntry()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            saveEntry()
        }
    }
    
    private func loadExistingEntry() {
        let targetDate = DateUtils.stripToDay(date)
        let descriptor = FetchDescriptor<DailyEntry>(
            predicate: #Predicate<DailyEntry> { entry in
                entry.date == targetDate
            }
        )
        
        do {
            let entries = try modelContext.fetch(descriptor)
            if let entry = entries.first {
                existingEntry = entry
                content = entry.content
            }
        } catch {
            print("Failed to fetch existing entry: \(error)")
        }
    }
    
    private func saveEntry() {
        print("Saving entry for date: \(date)")
        print("Content: '\(content)'")
        
        if let existing = existingEntry {
            print("Updating existing entry")
            existing.content = content
            existing.updatedAt = Date()
        } else {
            print("Creating new entry")
            let newEntry = DailyEntry(date: date, content: content)
            modelContext.insert(newEntry)
            existingEntry = newEntry
        }
        
        do {
            try modelContext.save()
            print("Entry saved successfully")
            
            // 위젯 데이터 업데이트 (오늘 날짜인 경우만)
            if DateUtils.stripToDay(date) == DateUtils.today() {
                updateWidgetData()
            }
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
    
    private func updateWidgetData() {
        // UserDefaults를 통해 위젯에 데이터 전달
        guard let userDefaults = UserDefaults(suiteName: "group.com.goopy") else {
            print("Failed to access App Group UserDefaults")
            return
        }
        
        let colorIndex = max(0, min(6, existingEntry?.colorIndex ?? 0))
        
        userDefaults.set(content, forKey: "todayContent")
        userDefaults.set(colorIndex, forKey: "todayColorIndex")
        userDefaults.synchronize()
        
        print("Widget data updated from InputView: content='\(content)', colorIndex=\(colorIndex)")
        
        // 위젯 새로고침 요청
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    InputView(date: Date())
        .preferredColorScheme(.dark)
}

