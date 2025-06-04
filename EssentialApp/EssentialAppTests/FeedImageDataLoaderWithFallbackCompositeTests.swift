//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/3/25.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImages() {
        let (_, primaryLoaderSpy, fallbackLoaderSpy) = makeSUT()
        
        XCTAssertTrue(primaryLoaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let (sut, primaryLoaderSpy, fallbackLoaderSpy) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoaderSpy.loadedURLs, [url], "Expected loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackLoaderWhenPrimaryLoaderFails() {
        let (sut, primaryLoaderSpy, fallbackLoaderSpy) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        primaryLoaderSpy.complete(with: anyNSError())
        
        XCTAssertEqual(primaryLoaderSpy.loadedURLs, [url], "Expected loaded URLs in the primary loader")
        XCTAssertEqual(fallbackLoaderSpy.loadedURLs, [url], "Expected loaded URLs in the fallback loader")
    }
    
    func test_cancelLoadImageData_cancelsPrimaryLoaderTask() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        
        task.cancel()
        
        XCTAssertEqual(primaryLoader.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
        XCTAssertTrue(fallbackLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
    }
    
    func test_cancelLoadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        primaryLoader.complete(with: anyNSError())
        task.cancel()
        
        XCTAssertTrue(primaryLoader.cancelledURLs.isEmpty, "Expected no cancelled URLs in the primary loader")
        XCTAssertEqual(fallbackLoader.cancelledURLs, [url], "Expected to cancel URL loading from fallback loader")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let (sut, primaryLoader, _) = makeSUT()
        let expectedData = anyData()
        
        expect(sut, toCompleteWith: .success(expectedData)) {
            primaryLoader.complete(with: expectedData)
        }
    }
    
    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let expectedData = anyData()
        
        expect(sut, toCompleteWith: .success(expectedData)) {
            primaryLoader.complete(with: anyNSError())
            fallbackLoader.complete(with: expectedData)
        }
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackLoaderFailure() {
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        let expectedError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(expectedError)) {
            primaryLoader.complete(with: expectedError)
            fallbackLoader.complete(with: expectedError)
        }
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderWithFallbackComposite, primaryLoader: LoaderSpy, fallbackLoader: LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primaryLoader: primaryLoader,
            fallbackLoader: fallbackLoader
        )
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)

            case (.failure, .failure):
                break

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        private(set) var cancelledURLs = [URL]()
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private var completions = [(FeedImageDataLoader.Result) -> Void]()
        
        func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            completions.append(completion)
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
