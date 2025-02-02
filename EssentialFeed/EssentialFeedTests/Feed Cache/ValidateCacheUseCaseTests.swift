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
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7Days = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        sut.validateCache { _ in }
        
        feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: lessThan7Days)
        XCTAssertEqual(feedStore.receivedMessages, [.retreive])
    }
    
    //MARK: Helpers
    
    private func anyNSError() -> NSError {
        NSError(domain: "1", code: 1)
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let items = [uniqueImage(), uniqueImage()]
        let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (items, localItems)
    }
    
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "http://a-url.com/")!
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        trackForMemeoryLeaks(feedStore, file: file, line: line)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return (feedStore, sut)
    }
}
