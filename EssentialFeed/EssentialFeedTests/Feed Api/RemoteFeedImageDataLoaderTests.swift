//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/15/25.
//

import XCTest
import EssentialFeed



class RemoteFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequests() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        
        expect(sut, toCompleteWith: .failure(error)) {
            client.complete(with: anyNSError())
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200Response() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200ResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
            
        expect(sut, toCompleteWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData())
        }
    }
    
    func test_loadImageData_deliversDataOn200Response() {
        let (sut, client) = makeSUT()
        let data = anyData()
            
        expect(sut, toCompleteWith: .success(data)) {
            client.complete(withStatusCode: 200, data: data)
        }
    }
    
    func test_loadImageData_doesNotDeliverDataAfterInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        let data = anyData()
        
        var receivedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { receivedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: data)

        XCTAssertTrue(receivedResults.isEmpty, "Expected no results, but got: \(receivedResults)")
    }
    
    func test_loadImageData_cancellingCancellsHTTPRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        
        XCTAssertTrue(client.cancelledURLs.isEmpty)
        task.cancel()
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertEqual(client.cancelledURLs, [url], "Expected to cancel request to \(url), but got: \(client.cancelledURLs)")
    }
    
    func test_loadImageData_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        var receivedResults: [FeedImageDataLoader.Result] = []
        let task = sut.loadImageData(from: url) { receivedResults.append($0) }
        
        task.cancel()
        client.complete(withStatusCode: 200, data: anyData())
        client.complete(withStatusCode: 404, data: anyData())
        client.complete(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty, "Expected no result, but got: \(receivedResults)")
    }
    
    // MARK: Helpers
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait to complete")
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
}
