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
        var receivedError: Error?
        
        let exp = expectation(description: "wait to complete")
        sut.load() { result in
            switch result {
            case let .failure(error):
                receivedError = error
            case .success:
                XCTFail("Expected failure, but got \(result)")
            }
            exp.fulfill()
        }
        
        feedStore.completeRetreival(with: expectedError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    func test_load_deliversNoImagesWithEmptyCache() {
        let (feedStore, sut) = makeSUT()
        var receivedImages: [FeedImage]?
        
        let exp = expectation(description: "wait to complete")
        sut.load() { result in
            switch result {
            case .failure:
                XCTFail("Expected success, but got \(result)")
            case let .success(images):
                receivedImages = images
            }
            exp.fulfill()
        }
        
        feedStore.completeWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedImages, [])
    }
    
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
