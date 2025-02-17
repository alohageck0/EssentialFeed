//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/16/25.
//

import EssentialFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ expected: (feed: [LocalFeedImage], currentDate: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for retreival to complete")
        var insertionError: Error?
        sut.insert(expected.feed, expected.currentDate) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for deletion to complete")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetreive expectedResult: RetreiveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for retreival to complete")
        sut.retreive { result in
            switch (expectedResult, result) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expectedFeed, expectedTimeStamp), .found(retreivedFeed, retreivedTimestamp)):
                XCTAssertEqual(expectedFeed, retreivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimeStamp, retreivedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected retreiving \(expectedResult) but got \(result)")
            }
            exp.fulfill()
        }
    
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: FeedStore, toRetreiveTwice expectedResult: RetreiveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetreive: expectedResult, file: file, line: line)
        expect(sut, toRetreive: expectedResult, file: file, line: line)
    }
}

