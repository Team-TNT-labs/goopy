//
//  DailyEntry.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import Foundation
import SwiftData

@Model
final class DailyEntry {
    var id: String
    var date: Date
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var colorIndex: Int
    
    init(date: Date, content: String) {
        self.id = DateUtils.stripToDay(date).description
        self.date = DateUtils.stripToDay(date)
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.colorIndex = 0 // 기본 색상 (어두운 회색)
    }
    
    func updateContent(_ newContent: String) {
        self.content = newContent
        self.updatedAt = Date()
    }
    
    func updateColor(_ newColorIndex: Int) {
        // 색상 인덱스 범위 검증 (0-6)
        self.colorIndex = max(0, min(6, newColorIndex))
        self.updatedAt = Date()
    }
}

