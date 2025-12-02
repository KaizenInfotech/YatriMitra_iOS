//
//  TimerManger.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 10/10/24.
//

import Foundation


class TimerManager {
    static let shared = TimerManager()  // Singleton instance
    private var timers: [Timer] = []    // Array to hold all timers

    private init() {}  // Private init to enforce singleton pattern

    func registerTimer(_ timer: Timer) {
        timers.append(timer)
    }

    func stopAllTimers() {
        DispatchQueue.global().async { [self] in
            for timer in timers {
                timer.invalidate()
            }
            timers.removeAll()  // Clear the list of timers
        }
    }
}
