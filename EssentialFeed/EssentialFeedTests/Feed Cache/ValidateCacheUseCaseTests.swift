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
    
    //MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        trackForMemeoryLeaks(feedStore, file: file, line: line)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return (feedStore, sut)
    }
}
