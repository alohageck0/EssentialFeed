//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/27/25.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    enum Error: Swift.Error {
        case failed
    }
    
    let store: FeedImageDataStore
    
    init(_ store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { _ in
            completion(.failure(Error.failed))
        }
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromUrl_requestsStoredDataFromUrl() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in
        }
        
        XCTAssertEqual(store.receivedMessages, [.retreive(forURL: url)])
    }
    
    func test_loadImageDataFromUrl_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(LocalFeedImageDataLoader.Error.failed)) {
            store.complete(with: anyNSError())
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            _ = sut.loadImageData(from: anyURL()) { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)

                case (.failure(let receivedError as LocalFeedImageDataLoader.Error),
                      .failure(let expectedError as LocalFeedImageDataLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                }

                exp.fulfill()
            }

            action()
            wait(for: [exp], timeout: 1.0)
        }
    
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retreive(forURL: URL)
        }
        
        var receivedMessages = [Message]()
        var completions = [(FeedImageDataStore.Result) -> Void]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append(.retreive(forURL: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
    }
}
