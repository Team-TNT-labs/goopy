//
//  goopyApp.swift
//  goopy
//
//  Created by go on 10/10/25.
//

import SwiftUI
import SwiftData

@main
struct goopyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DailyEntry.self)
    }
}

