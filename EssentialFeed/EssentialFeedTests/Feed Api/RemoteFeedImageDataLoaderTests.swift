//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/15/25.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.failure(Error.invalidData))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

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
    
    // MARK: Helpers
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait to complete")
        _ = sut.loadImageData(from: url) { receivedResult in
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
    
    private func anyData() -> Data {
        return Data("any data".utf8)
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
    
    private class HTTPClientSpy: HTTPClient {
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url}
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
