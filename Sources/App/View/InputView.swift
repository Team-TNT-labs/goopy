//
//  InputView.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI
import SwiftData
import UIKit

struct InputView: View {
    @Environment(\.modelContext) private var modelContext

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var content: String = ""
    @State private var existingEntry: DailyEntry?
    @State private var isTextFieldFocused: Bool = false

    let date: Date

    // TextEditor 폰트. PostScript명 기반(AppFont)으로 KoPubWorld Batang(명조/serif) 고정.
    private static let editorFont: UIFont = .kpubWorld(size: 19)

    var body: some View {
        VStack(spacing: 0) {

            // Text editor
            // 한글 IME 조합 중 serif가 유지되도록 UITextView 기반 에디터 사용
            SerifTextEditor(
                text: $content,
                isFirstResponder: isTextFieldFocused,
                font: Self.editorFont,
                textColor: UIColor(isDarkMode ? Color.darkText : Color.lightText)
            )
            .background(Color.clear)
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(isDarkMode ? Color.darkBackground : Color.lightBackground)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            loadExistingEntry()
            // 키보드 자동 표시
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
        .onChange(of: content) { _, newContent in
            // 입력 즉시 모델에 반영한다. DayPageView 등 @Query 구독 뷰가
            // 뒤로가기 시점과 무관하게 항상 최신 내용을 보여주게 하는 핵심.
            applyContent(newContent)
        }
        .onDisappear {
            finalizeEntry()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            finalizeEntry()
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

    private func applyContent(_ newContent: String) {
        if let entry = existingEntry {
            // 기존 entry는 Observable 모델 변이만으로 구독 뷰가 즉시 갱신된다.
            // 로드 직후 onChange 발화 등 내용이 같을 때는 변이하지 않는다 (updatedAt 오염 방지).
            guard entry.content != newContent else { return }
            entry.updateContent(newContent)
        } else if !newContent.isEmpty {
            // 빈 내용으로는 entry를 만들지 않는다 (열었다 닫기만 해도 빈 entry가 쌓이는 것 방지).
            let newEntry = DailyEntry(date: date, content: newContent)
            modelContext.insert(newEntry)
            existingEntry = newEntry
            // 신규 entry가 @Query 결과에 바로 등장하도록 1회 저장
            save()
        }
    }

    private func finalizeEntry() {
        save()

        // 위젯 데이터 업데이트 (오늘 날짜인 경우만 — 리로드 예산 때문에 종료 시점에만 수행)
        if DateUtils.stripToDay(date) == DateUtils.today() {
            WidgetDataStore.sync(
                content: existingEntry?.content ?? "",
                colorIndex: existingEntry?.colorIndex ?? 0,
                isDarkMode: isDarkMode
            )
        }
    }

    private func save() {
        guard modelContext.hasChanges else { return }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DailyEntry.self, configurations: config)

    InputView(date: Date())
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
