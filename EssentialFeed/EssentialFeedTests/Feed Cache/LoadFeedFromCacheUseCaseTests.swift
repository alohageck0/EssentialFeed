//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 1/30/25.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() throws {
        let (feedStore, _) = makeSUT()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_load_requestsRetreival() {
        let (feedStore, sut) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.retreive])
    }
    
    func test_load_failsOnRetreivalError() {
        let (feedStore, sut) = makeSUT()
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(expectedError), when: {
            feedStore.completeRetreival(with: expectedError)
        })
    }
    
    func test_load_deliversNoImagesWithEmptyCache() {
        let (feedStore, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            feedStore.completeWithEmptyCache()
        })
    }
    
    func test_load_deliversCachedImagesOnLessThan7DaysCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7Days = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        expect(sut, toCompleteWith: .success(feed.models), when: {
            feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: lessThan7Days)
        })
    }
    
    func test_load_deliversNoImagesOn7DaysCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let _7Days = fixedCurrentDate.adding(days: -7)
        let feed = uniqueImageFeed()
        
        expect(sut, toCompleteWith: .success([]), when: {
            feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: _7Days)
        })
    }
    
    func test_load_deliversNoImagesMoreThan7DaysCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let moreThanSevenDays = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        expect(sut, toCompleteWith: .success([]), when: {
            feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: moreThanSevenDays)
        })
    }
    
    func test_load_hasNoSideffectsOnRetreivalError() {
        let (feedStore, sut) = makeSUT()
        
        sut.load { _ in }
        
        feedStore.completeRetreival(with: anyNSError())
        XCTAssertEqual(feedStore.receivedMessages, [.retreive])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (feedStore, sut) = makeSUT()
        
        sut.load { _ in }
        
        feedStore.completeWithEmptyCache()
        XCTAssertEqual(feedStore.receivedMessages, [.retreive])
    }
    
    func test_load_hasNoSideEffectsOnLessThanSevenDaysCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let lessThan7Days = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let feed = uniqueImageFeed()
        
        sut.load { _ in
            
        }
        
        feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: lessThan7Days)
        XCTAssertEqual(feedStore.receivedMessages, [.retreive])
    }
    
    func test_load_deletesSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let _7Days = fixedCurrentDate.adding(days: -7)
        let feed = uniqueImageFeed()
        
        sut.load { _ in
            
        }
        
        feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: _7Days)
        XCTAssertEqual(feedStore.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_load_deletesMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (feedStore, sut) = makeSUT(currentDate: { fixedCurrentDate })
        let moreThanSevenDays = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let feed = uniqueImageFeed()
        
        sut.load { _ in
            
        }
        
        feedStore.completeRetreivalSuccessfully(with: feed.local, timestamp: moreThanSevenDays)
        XCTAssertEqual(feedStore.receivedMessages, [.retreive, .deleteCachedFeed])
    }
    
    func test_load_doesNotDeleverImagesWhenSUTInstanceHasBeenDeallocated() {
        var sut: LocalFeedLoader?
        let store = FeedStoreSpy()
        sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        store.completeWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: Helpers
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait to complete")
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), but received \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
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

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        self.addingTimeInterval(seconds)
    }
}
