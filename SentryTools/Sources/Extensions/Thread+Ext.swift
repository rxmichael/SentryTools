//
//  Thread+Ext.swift
//  SentryTools
//
//  Created by Michael Eid on 8/1/25.
//

import Foundation

public extension Thread {

    static var readableCallStack : [String] {
        Thread
            .callStackSymbols // drop Thread.callStack
            .dropFirst(
            ).map { line in
            let parts = line.split(separator:" ")
            let index = parts[0]
            let module = parts[1]
            let method = demangle("\(parts[3])")
            return "[\(module)] \(method)"
        }
    }
}

public typealias SwiftDemangle = @convention(c) (_ mangledName: UnsafePointer<CChar>?, _ mangledNameLength: Int, _ outputBuffer: UnsafeMutablePointer<CChar>?, _ outputBufferSize: UnsafeMutablePointer<Int>?, _ flags: UInt32) -> UnsafeMutablePointer<CChar>?

nonisolated(unsafe) public let RTLD_DEFAULT = dlopen(nil, RTLD_NOW)
nonisolated(unsafe) public let demangleSymbol = dlsym(RTLD_DEFAULT, "swift_demangle")!
public let cDemangle = unsafeBitCast(demangleSymbol, to: SwiftDemangle.self)

public func demangle(_ mangled: String) -> String {
    return mangled.withCString { cString in
        // Prepare output buffer size
        var size: Int = 0
        let ptr = cDemangle(cString, strlen(cString), nil, &size, 0)

        // Check if demangling was successful
        guard let result = ptr else { return mangled }

        // Convert demangled name to string
        let demangledName = String(cString: result)

        // Free memory allocated by swift_demangle (if necessary)
        free(result)

        return demangledName
    }
}
