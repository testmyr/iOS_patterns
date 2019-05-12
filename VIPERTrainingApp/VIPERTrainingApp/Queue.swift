//
//  Queue.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/12/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation

struct Queue<Element> {
    private var left:[Element] = []
    private var right:[Element] = []
    
    var size: Int {
        return left.count + right.count
    }
    
    mutating func enqueue(_ newElement: Element) {
        right.append(newElement)
    }
    mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}
