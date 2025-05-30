//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/30/25.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageData_storesData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, forURL: url)])
    }
    
    func test_saveImageDataForURL_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWith: failed()) {
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_saveImageDataForURL_succedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_saveImageDataForURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let storeSpy = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = .init(storeSpy)
        
        var receivedResult = [LocalFeedImageDataLoader.SaveResult]()

        _ = sut?.save(anyData(), for: anyURL()) { receivedResult.append($0) }
        
        sut = nil
        storeSpy.completeInsertionSuccessfully()
        
        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after cancelling task")
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> LocalFeedImageDataLoader.SaveResult {
        return .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            sut.save(anyData(), for: anyURL()) { receivedResult in
                switch (receivedResult, expectedResult) {
                case (.success, .success):
                    break

                case (.failure(let receivedError as LocalFeedImageDataLoader.SaveError),
                      .failure(let expectedError as LocalFeedImageDataLoader.SaveError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }

                exp.fulfill()
            }

            action()
            wait(for: [exp], timeout: 1.0)
        }
}
