//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 12/23/24.
//

import XCTest
import EssentialFeed
import Foundation

protocol HTTPClient {
    var requestedURLs: [URL] { get }
    func get(from url: URL)
}

struct RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    func load() {
        client.get(from: url)
    }
}

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    func get(from url: URL) {
        requestedURLs.append(url)
    }
}

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
    
    func makeSUT() -> (HTTPClient, RemoteFeedLoader) {
        let url = URL(string: "https://a-given-url.com")!
        let sut = RemoteFeedLoader(client: HTTPClientSpy(), url: url)
        return (sut.client, sut)
    }
}
