//
//  SentryTestApp.swift
//  SentryTest
//
//  Created by Michael Eid on 8/1/25.
//

import SwiftUI
import SentryTools

@main
struct SentryTestApp: App {
    @State var threadMonitor: ThreadMonitor = .init()

    init() {
        CrashReporter.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(threadMonitor)
        }
    }
}
