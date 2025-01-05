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
            
        }.resume()
    }
    
    
}

class URLSesstionHTTPClientTests: XCTestCase {
    func test_getFromURLResumesDataTaskWithUrl() {
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url, task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in
            
        }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    private class URLSessionSpy: URLSession {
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(_ url: URL, _ task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {
            
        }
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
        
}
