//
//  ValidateCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/2/25.
//

import XCTest
import EssentialFeed

final class ValidateCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() throws {
        let (feedStore, _) = makeSUT()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetreivalError() {
        let (feedStore, sut) = makeSUT()
        
        sut.validateCache { _ in }
        
        feedStore.completeRetreival(with: anyNSError())
        XCTAssertEqual(feedStore.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (feedStore, sut) = makeSUT()
        
        sut.validateCache { _ in }
        
        feedStore.completeWithEmptyCache()
        XCTAssertEqual(feedStore.receivedMessages, [.retreive])
    }
    
    //MARK: Helpers
    
    private func anyNSError() -> NSError {
        NSError(domain: "1", code: 1)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        trackForMemeoryLeaks(feedStore, file: file, line: line)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return (feedStore, sut)
    }
}
