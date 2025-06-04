//
//  XCTestCase+MemoryLeakTracker.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
