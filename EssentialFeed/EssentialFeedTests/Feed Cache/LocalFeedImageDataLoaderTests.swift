//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/27/25.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    let store: FeedImageDataStore
    
    init(_ store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
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
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retreive(forURL: URL)
        }
        
        func retrieve(dataForURL url: URL) {
            receivedMessages.append(.retreive(forURL: url))
        }
        
        var receivedMessages = [Message]()
    }
}
