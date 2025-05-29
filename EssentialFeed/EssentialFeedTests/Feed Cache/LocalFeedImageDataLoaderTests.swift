//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/27/25.
//

import XCTest
import EssentialFeed

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
        
        expect(sut, toCompleteWith: failed()) {
            store.completeRetreival(with: anyNSError())
        }
    }
    
    func test_loadImageDataFromUrl_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound()) {
            store.completeRetreival(with: .none)
        }
    }
    
    func test_loadImageDataFromUrl_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        
        expect(sut, toCompleteWith: .success(data)) {
            store.completeRetreival(with: data)
        }
    }
    
    func test_loadImageDataFromUrl_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        
        var receivedResult = [FeedImageDataLoader.Result]()
        
        let task = sut.loadImageData(from: anyURL()) { receivedResult.append($0) }
        task.cancel()
        
        store.completeRetreival(with: anyNSError())
        store.completeRetreival(with: anyData())
        store.completeRetreival(with: .none)

        
        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromUrl_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let storeSpy = StoreSpy()
        var sut: LocalFeedImageDataLoader? = .init(storeSpy)
        
        var receivedResult = [FeedImageDataLoader.Result]()

        _ = sut?.loadImageData(from: anyURL()) { receivedResult.append($0) }
        
        sut = nil
        storeSpy.completeRetreival(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_saveImageData_storesData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, forURL: url)])
    }
    
    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func failed() -> FeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            _ = sut.loadImageData(from: anyURL()) { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedData), .success(expectedData)):
                    XCTAssertEqual(receivedData, expectedData, file: file, line: line)

                case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError),
                      .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
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
            case insert(data: Data, forURL: URL)
        }
        
        var receivedMessages = [Message]()
        var retreivalCompletions = [(FeedImageDataStore.RetreivalResult) -> Void]()
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetreivalResult) -> Void) {
            receivedMessages.append(.retreive(forURL: url))
            retreivalCompletions.append(completion)
        }
        
        func insert(data: Data, forURL url: URL, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, forURL: url))
            retreivalCompletions.append(completion)
        }
        
        func completeRetreival(with error: Error, at index: Int = 0) {
            retreivalCompletions[index](.failure(error))
        }
        
        func completeRetreival(with data: Data? = nil, at index: Int = 0) {
            retreivalCompletions[index](.success(data))
        }
    }
}
