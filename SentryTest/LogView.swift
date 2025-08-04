//
//  LogView.swift
//  SentryTest
//
//  Created by Michael Eid on 8/1/25.
//

import SentryTools
import SwiftUI

struct LogView: View {

    @State private var log = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        TextEditor(text: $log)
            .contentMargins(.horizontal, 16.0, for: .scrollContent)
            .task {
                log = prepareLogData()
            }
            .alert(
                Text("Are you sure you want to cleat the logs?"),
                isPresented: $showDeleteConfirmation,
                actions: {
                    Button("Cancel", role: .cancel) {
                    }
                    Button("Clear", role: .destructive) {
                        Logger.clearLogs()
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            self.showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "clear")
                        }
                    }
                }
            }
    }

    func prepareLogData() -> String {
        let filePath = Logger.filePath
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = content.split(separator: "\n")
            if lines.count > 500 {
                let last100Lines = lines.suffix(1500)
                return last100Lines.joined(separator: "\n")
            }
            return content
        } catch {
            print("Failed to read log data: \(error)")
            return "Failed to load log data."
        }
    }
}

#Preview {
    LogView()
}
