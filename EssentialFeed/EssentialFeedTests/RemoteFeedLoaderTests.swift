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

    func test_init_does_not_request_data_from_url() async throws {
        let url = URL(string: "https://a-given-url.com")!
        let sut = RemoteFeedLoader(client: HTTPClientSpy(), url: url)

        XCTAssertTrue(sut.client.requestedURLs.isEmpty)
    }

}
