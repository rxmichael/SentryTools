//
//  LockedType.swift
//  SentryTools
//
//  Created by Michael Eid on 8/1/25.
//


import Foundation

public enum LockedType {
    /// Uses NSLock
    case `default`
    /// Uses NSRecursiveLock
    case recursive
}

public class Locked<Content> {
    private var contentStorage: Content
    private let lock: NSLocking

    @inline(__always) public var content: Content {
        lock.lock()
        let content = contentStorage
        lock.unlock()
        return content
    }

    /// Initializes `Locked` with a content behind a lock with a type ``LockedType/default`` or ``LockedType/recursive``
    public init(_ content: Content, type: LockedType = .default) {
        self.contentStorage = content
        self.lock = type == .default ? NSLock() : NSRecursiveLock()
    }

      @inline(__always)
      @discardableResult
      public func perform<T>(operation: (inout Content) throws -> T) throws -> T {
        lock.lock()
        defer { lock.unlock() }
        return try operation(&contentStorage)
      }

      @inline(__always)
      @discardableResult
      public func perform<T>(operation: (inout Content) -> T) -> T {
        lock.lock()
        let result = operation(&contentStorage)
        lock.unlock()
        return result
      }
}

extension Locked: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Locked: \(contentStorage)"
  }
}
