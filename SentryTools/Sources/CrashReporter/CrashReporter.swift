//
//  CrashLogger.swift
//  SentryTools
//
//  Created by Michael Eid on 4/10/25.
//

import Foundation

public protocol CrashReporting {
    func initialize()
    func logCrash(crash: CrashReport)
}

public final class CrashReporter: CrashReporting, @unchecked Sendable {
    public static let shared = CrashReporter()

    public func initialize() {
        NSSetUncaughtExceptionHandler {
            CrashReporter.shared.handleException($0)
        }

        CrashSignal.allCases.forEach {
            signal($0.value) { CrashReporter.shared.handleSignal($0) }
        }
    }

    public func handleException(_ exception: NSException) {
        logCrash(crash: .init(type:  .exception(exception), trace: Thread.readableCallStack))
    }

    public func handleSignal(_ signal: Int32) {
        if let crashSignal = CrashSignal(signal) {
            logCrash(crash: .init(type:  .signal(crashSignal), trace: Thread.readableCallStack))
        }
    }

    public func logCrash(crash: CrashReport) {
        let message = """
        ---
        🚨 CRASH:
        Description: \(crash.description)
        Reason: \(crash.reason ?? "nil")
        Trace: \(crash.trace)
        ---
        """
        Logger.info(message)
    }
}
