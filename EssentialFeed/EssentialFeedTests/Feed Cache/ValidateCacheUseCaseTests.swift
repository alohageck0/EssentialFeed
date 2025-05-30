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
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completeRetreival(with: anyNSError())
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetreival(with: anyNSError())
            store.completeDeletionSuccessfully()
        }
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetreivalSuccessfully(with: [], timestamp: Date())
        }
    }
    
    //MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        trackForMemoryLeaks(feedStore, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (feedStore, sut)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let saveExp = expectation(description: "Wait for save completion")
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            saveExp.fulfill()
        }
        
        action()
        
        wait(for: [saveExp], timeout: 1.0)
    }
}
