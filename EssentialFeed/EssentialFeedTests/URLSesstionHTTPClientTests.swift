//
//  URLSesstionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 1/5/25.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (EssentialFeed.HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, _ in
            
        }
    }
    
    
}

class URLSesstionHTTPClientTests: XCTestCase {
    func test_getFromURLcreatesDataTaskWithUrl() {
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in
            
        }
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
        
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
        
}
