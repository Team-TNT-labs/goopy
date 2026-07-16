//
//  WidgetDataStore.swift
//  goopy
//
//  위젯과 공유하는 앱 그룹 데이터의 단일 창구.
//  호출 시점의 최신 값을 받아 그대로 기록한다 — 뷰에 캐싱된 stale 상태를 넘기지 말 것.
//

import Foundation
import WidgetKit

enum WidgetDataStore {
    private static let suiteName = "group.com.goopy"

    static func sync(content: String, colorIndex: Int, isDarkMode: Bool) {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            print("Failed to access App Group UserDefaults")
            return
        }

        defaults.set(content, forKey: "todayContent")
        defaults.set(max(0, min(6, colorIndex)), forKey: "todayColorIndex")
        defaults.set(isDarkMode, forKey: "isDarkMode")

        WidgetCenter.shared.reloadAllTimelines()
    }
}
