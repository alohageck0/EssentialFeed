//
//  XCTestCase+MemoryLeakTracker.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 1/8/25.
//

import Foundation
import XCTest

public extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dealocated. Potential memory leak", file: file, line: line)
        }
    }
}
