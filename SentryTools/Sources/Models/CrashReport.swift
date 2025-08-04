//
//  CrashReport.swift
//  SentryTools
//
//  Created by Michael Eid on 8/1/25.
//

import Foundation

public struct CrashReport {
    let type: CrashType
    let trace: [String]

    public var description: String {
        return switch type {
        case let .exception(exception):
            exception.description
        case let .signal(signal):
            signal.name
        }
    }

    public var reason: String? {
        return switch type {
        case let .exception(exception):
            exception.reason
        case .signal:
            nil
        }
    }
}

public enum CrashType {
    case signal(CrashSignal)
    case exception(NSException)
}
