//
//  CrashSignal.swift
//  SentryTools
//
//  Created by Michael Eid on 8/1/25.
//

import Foundation

public enum CrashSignal: Sendable, CaseIterable {
    case hangup
    case interrupt
    case quit
    case illegal
    case trap
    case abort
    case floatingPointError
    case kill
    case segmentationFault
    case pipeError
    case termination

    public init?(_ int: Int32) {
        for signal in Self.allCases {
            if int == signal.value {
                self = signal
                return
            }
        }
        return nil
    }

    public init?(_ name: String) {
        for signal in Self.allCases {
            if name.lowercased() == signal.name.lowercased() || name.lowercased() == signal.name.lowercased().deletingPrefix("sig") {
                self = signal
                return
            }
        }
        return nil
    }

    public var value: Int32 {
        switch self {
        case .hangup: return SIGHUP
        case .interrupt: return SIGINT
        case .quit: return SIGQUIT
        case .illegal: return SIGILL
        case .trap: return SIGTRAP
        case .abort: return SIGABRT
        case .floatingPointError: return SIGFPE
        case .kill: return SIGKILL
        case .segmentationFault: return SIGSEGV
        case .pipeError: return SIGPIPE
        case .termination: return SIGTERM
        }
    }

    public var name: String {
        switch self {
        case .hangup: "SIGHUP"
        case .interrupt: "SIGINT"
        case .quit: "SIGQUIT"
        case .illegal: "SIGILL"
        case .trap: "SIGTRAP"
        case .abort: "SIGABRT"
        case .floatingPointError: "SIGFPE"
        case .kill: "SIGKILL"
        case .segmentationFault: "SIGSEGV"
        case .pipeError: "SIGPIPE"
        case .termination: "SIGTERM"
        }
    }
}
