import SentryTools
import SwiftUI

struct CrashExampleView: View {
    @Environment(ThreadMonitor.self) var threadMonitor
    @State private var showingCrashAlert = false
    @State private var selectedCrashType = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Thread Monitoring Section
                    GroupBox("Thread Monitoring") {
                        VStack(spacing: 12) {
                            Button {
                                simulateMainThreadBlock()
                            } label: {
                                Text("Trigger Main Thread Hang (7s)")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }

                    // Crash Testing Section
                    GroupBox("Crash Testing") {
                        VStack(spacing: 12) {

                            // Memory-related crashes
                            Group {
                                crashButton("Segmentation Fault", "segmentationFault", .red)
                                crashButton("Null Pointer", "nullPointerDereference", .red)
                                crashButton("Memory Corruption", "memoryCorruption", .red)
                                crashButton("Stack Overflow", "stackOverflow", .red)
                            }

                            // Signal-related crashes
                            Group {
                                crashButton("Illegal Instruction", "illegalInstruction", .purple)
                                crashButton("Floating Point Error", "floatingPointError", .purple)
                                crashButton("Abort Signal", "abort", .purple)
                            }

                            // Exception-based crashes
                            Group {
                                crashButton("Array Out of Bounds", "arrayOutOfBounds", .blue)
                                crashButton("Invalid Argument", "invalidArgument", .blue)
                                crashButton("Custom Exception", "customException", .blue)
                            }

                            // Assertion failures
                            Group {
                                crashButton("Assertion Failure", "assertionFailure", .green)
                                crashButton("Precondition Failure", "preconditionFailure", .green)
                            }
                        }
                    }

                    // Info Section
                    GroupBox("Info") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚠️ Warning: Crash buttons will terminate the app!")
                                .font(.caption)
                                .foregroundColor(.red)

                            Text("Colors indicate crash type:")
                                .font(.caption)
                                .bold()

                            HStack {
                                Circle().fill(.red).frame(width: 8, height: 8)
                                Text("Memory errors")
                                    .font(.caption2)
                            }

                            HStack {
                                Circle().fill(.purple).frame(width: 8, height: 8)
                                Text("Signal errors")
                                    .font(.caption2)
                            }

                            HStack {
                                Circle().fill(.blue).frame(width: 8, height: 8)
                                Text("Exceptions")
                                    .font(.caption2)
                            }

                            HStack {
                                Circle().fill(.green).frame(width: 8, height: 8)
                                Text("Assertions")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Crash Testing")
        }
        .onAppear {
            threadMonitor.startMonitoring()
        }
        .alert("Confirm Crash", isPresented: $showingCrashAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Crash App", role: .destructive) {
                CrashTriggers.triggerCrash(named: selectedCrashType)
            }
        } message: {
            Text("This will crash the app to test crash reporting. Are you sure?")
        }
    }

    @ViewBuilder
    private func crashButton(_ title: String, _ crashType: String, _ color: Color) -> some View {
        Button {
            selectedCrashType = crashType
            showingCrashAlert = true
        } label: {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    @MainActor
    func simulateMainThreadBlock(duration: TimeInterval = 7.0) {
        let endTime = Date().addingTimeInterval(duration)
        while Date() < endTime {
        }
    }
}
