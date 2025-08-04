//
//  MainTabView.swift
//  SentryTest
//
//  Created by Michael Eid on 8/1/25.
//

import SwiftUI

struct MainTabView: View {
    @State var selectedTabIndex = 0

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            CrashExampleView().tabItem {
                Label("Crash Example", systemImage: "map")
            }.tag(1)
            LogView().tabItem {
                Label("Log View", systemImage: "map")
            }.tag(2)
        }
    }
}
