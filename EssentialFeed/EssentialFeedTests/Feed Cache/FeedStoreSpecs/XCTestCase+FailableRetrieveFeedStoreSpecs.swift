//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/16/25.
//

import Foundation
import EssentialFeed
import XCTest

extension FailableRetreiveSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetreive: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetreiveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
