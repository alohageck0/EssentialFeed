//
//  XCTestCase+FailableInsertSpecs.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/16/25.
//

import XCTest
import EssentialFeed

extension FailableInsertSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        expect(sut, toRetreive: .success(.none), file: file, line: line)
    }
}
