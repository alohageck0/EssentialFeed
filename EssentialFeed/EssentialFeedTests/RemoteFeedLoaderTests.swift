//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 12/23/24.
//

import XCTest
import EssentialFeed
import Foundation

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestData() async throws {
        let (client, _) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_appendsUrl() {
        let (client, sut) = makeSUT()
        
        sut.load { _ in }
        XCTAssertTrue(client.requestedURLs.count == 1)
    }
    
    func test_load_executesTwice() {
        let (client, sut) = makeSUT()
        
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertTrue(client.requestedURLs.count == 2)
    }
    
    func test_load_deliversError() {
        let (client, sut) = makeSUT()
        
        let clientError = NSError(domain: "", code: 1)
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load() {
            capturedErrors.append($0)
        }
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200() {
        let (client, sut) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in

            var capturedErrors = [RemoteFeedLoader.Error]()
            
            sut.load() {            capturedErrors.append($0)
            }
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURL = url
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)
            messages[index].completion(.success(response!))
        }
    }
    
    private func makeSUT() -> (HTTPClientSpy, RemoteFeedLoader) {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
}
