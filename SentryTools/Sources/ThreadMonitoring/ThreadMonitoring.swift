//
//  ThreadMonitoring.swift
//  SentryTools
//
//  Created by Michael Eid on 8/1/25.
//

import Foundation
import UIKit

public protocol ThreadMonitoring {
    func startMonitoring()
    func stopMonitoring()
}

@Observable
public class ThreadMonitor: ThreadMonitoring, @unchecked Sendable {
    private let lock: NSLock = .init()
    private let targetQueue: DispatchQueue
    private let notificationCenter: NotificationCenter
    private let threshold: TimeInterval
    private var isMainThreadBLocked: Locked<Bool> = .init(false)
    private var isApplicationActive: Locked<Bool> = .init(true)
    private let semaphore: DispatchSemaphore = .init(value: 0)
    private var thread: Thread?

    public init(targetQueue: DispatchQueue = .main, notificationCenter: NotificationCenter = .default, threshold: TimeInterval = 4.0) {
        self.targetQueue = targetQueue
        self.notificationCenter = notificationCenter
        self.threshold = threshold
    }

    public func startMonitoring() {
        setupObservers()
        lock.withLock {
            Thread.detachNewThreadSelector(#selector(runThread), toTarget: self, with: nil)
        }
    }

    public func stopMonitoring() {
        notificationCenter.removeObserver(self)
        lock.withLock {
            thread?.cancel()
            thread = nil
        }
    }

    func setupObservers() {
        notificationCenter.addObserver(self, selector: #selector(setApplicationActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setApplicationInactive), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(setApplicationInactive), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func setApplicationActive() {
        isApplicationActive.perform { $0 = true }
    }

    @objc func setApplicationInactive() {
        isApplicationActive.perform { $0 = false }
    }

    @objc func runThread() {
        let newThread = Thread.current
        newThread.qualityOfService = .background
        lock.withLock {
            self.thread = newThread
        }

        guard let thread = thread else { return }
        loopThread(condition: { !thread.isCancelled }, loop: { Thread.sleep(forTimeInterval: self.threshold) } )
    }

    func loopThread(condition: () -> Bool, loop: () -> Void) {
        let startTime = Date()
        while condition() {
            if isApplicationActive.content {
                isMainThreadBLocked.perform { $0 = true }

                DispatchQueue.main.async { [isMainThreadBLocked, semaphore] in
                    isMainThreadBLocked.perform { $0 = false }
                    semaphore.signal()
                }

                Thread.sleep(forTimeInterval: self.threshold)
                if isMainThreadBLocked.content {
                    let blockedDuration = Date().timeIntervalSince(startTime)
                    reportMainThreadBlocked(duration: blockedDuration)
                }
                _ = self.semaphore.wait(timeout: .distantFuture)
            } else {
                loop()
            }
        }
    }

    nonisolated private func reportMainThreadBlocked(duration: TimeInterval) {
        print("Main Thread Blocked with duration \(String(format: "%.2f", duration)) seconds")
    }

    deinit {
        stopMonitoring()
    }
}
