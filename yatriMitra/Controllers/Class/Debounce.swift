//
//  Debounce.swift
//  yatriMitra
//
//  Created by Kaizen Infotech Solutions Private Limited. on 18/12/24.
//

import UIKit

class Debouncer {
    private var delay: TimeInterval
    private var workItem: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func call(_ action: @escaping () -> Void) {
        // Cancel the previous work item if exists
        workItem?.cancel()
        
        // Create a new work item
        workItem = DispatchWorkItem(block: action)
        
        // Dispatch the work item after the specified delay
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
