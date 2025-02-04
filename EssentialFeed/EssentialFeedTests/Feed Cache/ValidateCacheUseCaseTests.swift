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
    
    func test_validateCache_doesNotDeletesNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        sut.validateCache { _ in }
        
        feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(feedStore.receivedMessages, [.retreive])
    }
    
    func test_validateCache_deletesOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let feed = uniqueImageFeed()
        
        sut.validateCache { _ in }
        
        feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: expirationTimestamp)
        XCTAssertEqual(feedStore.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validateCache_deletesExpiredCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        sut.validateCache { _ in }
        
        feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(feedStore.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheWhenSUTInstanceHasBeenDeallocated() {
        var sut: LocalFeedLoader?
        let store = FeedStoreSpy()
        sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache { _ in }
        
        sut = nil
        store.completeRetreival(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retreive])
    }
    
    //MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        trackForMemeoryLeaks(feedStore, file: file, line: line)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return (feedStore, sut)
    }
}
