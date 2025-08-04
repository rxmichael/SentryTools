//
//  CrashTriggers.swift
//  SentryTest
//
//  Created by Michael Eid on 8/1/25.
//


import Foundation
enum CrashTriggers {

    // MARK: - Segmentation Fault (SIGSEGV)
    static func triggerSegmentationFault() {
        let ptr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        ptr.initialize(to: 42)
        ptr.deallocate()
        print(ptr.pointee)
    }
    
    // MARK: - Illegal Instruction (SIGILL)
    static func triggerIllegalInstruction() {
        #if targetEnvironment(simulator)
        let invalidInstruction: () -> Void = unsafeBitCast(0x00000000 as UInt32, to: (() -> Void).self)
        invalidInstruction()
        #else
        // On device, we can trigger it differently
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 4)
        ptr.storeBytes(of: UInt32(0x00000000), as: UInt32.self) // Invalid instruction
        let function = unsafeBitCast(ptr, to: (() -> Void).self)
        function()
        #endif
    }
    
    // MARK: - Abort (SIGABRT)
    static func triggerAbort() {
        abort()
    }

    static func triggerAssertionFailure() {
        assert(false, "This is a test crash")
    }

    static func triggerPreconditionFailure() {
        preconditionFailure("This is a test crash")
    }
    
    // MARK: - NSException
    static func triggerArrayOutOfBounds() {
        let array = NSArray()
        _ = array.object(at: 10) // Will throw NSRangeException
    }

    static func triggerCustomException() {
        let exception = NSException(
            name: NSExceptionName("TestCrashException"),
            reason: "This is a test crash for crash reporting",
            userInfo: ["test": "data"]
        )
        exception.raise()
    }
    
    // MARK: - Stack Overflow (SIGSEGV)
    static func triggerStackOverflow() {
        func infiniteRecursion() {
            infiniteRecursion()
        }
        infiniteRecursion()
    }
    
    // MARK: - Memory Corruption
    static func triggerMemoryCorruption() {
        let ptr = UnsafeMutablePointer<Int>.allocate(capacity: 10)
        ptr.initialize(repeating: 42, count: 10)
        
        // Write beyond allocated memory
        for i in 0..<1000 {
            (ptr + i).pointee = i
        }
        
        ptr.deallocate()
    }
    
    // MARK: - Bus Error (SIGBUS) - Rare on iOS
    static func triggerBusError() {
        let data = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        data.withUnsafeBytes { bytes in
            // Try to read a 64-bit integer from an odd address (misaligned)
            let misalignedPtr = bytes.baseAddress!.advanced(by: 1)
            let ptr = misalignedPtr.assumingMemoryBound(to: UInt64.self)
            _ = ptr.pointee // May trigger SIGBUS on some architectures
        }
    }

    public static func triggerCrash(named crashType: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            switch crashType.lowercased() {
            case "segmentationfault":
                triggerSegmentationFault()
            case "illegalinstruction":
                triggerIllegalInstruction()
            case "abort":
                triggerAbort()
            case "assertionfailure":
                triggerAssertionFailure()
            case "preconditionfailure":
                triggerPreconditionFailure()
            case "arrayoutofbounds":
                triggerArrayOutOfBounds()
            case "customexception":
                triggerCustomException()
            case "stackoverflow":
                triggerStackOverflow()
            case "memorycorruption":
                triggerMemoryCorruption()
            case "buserror":
                triggerBusError()
            default:
                print("Unknown crash type: \(crashType)")
            }
        }
    }
}
