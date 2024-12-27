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
        
        sut.load()
        XCTAssertTrue(client.requestedURLs.count == 1)
    }
    
    func test_load_executesTwice() {
        let (client, sut) = makeSUT()
        
        sut.load()
        sut.load()
        XCTAssertTrue(client.requestedURLs.count == 2)
    }
    
    func test_load_deliversError() {
        let (client, sut) = makeSUT()
        
        client.error = NSError(domain: "", code: 1)
        var capturedError: RemoteFeedLoader.Error?
        
        sut.load() { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURL = url
            requestedURLs.append(url)
        }
    }
    
    private func makeSUT() -> (HTTPClientSpy, RemoteFeedLoader) {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (client, sut)
    }
}
