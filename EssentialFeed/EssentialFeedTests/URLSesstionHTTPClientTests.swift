//
//  URLSesstionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 1/5/25.
//

import Foundation
import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> SessionDataTask
}

protocol SessionDataTask {
    func resume()
}

class URLSessionHTTPClient: HTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
}

class URLSesstionHTTPClientTests: XCTestCase {
    func test_getFromURLResumesDataTaskWithUrl() {
        let url = URL(string: "http://a-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url, task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in
            
        }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let url = URL(string: "http://a-url.com")!
        let session = HTTPSessionSpy()
        let task = URLSessionDataTaskSpy()
        let error = NSError(domain: "an error", code: 1)
        session.stub(url, task, error)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "Wait to complete")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with \(error), got result \(result)")
            }
                        
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: SessionDataTask
            let error: Error?
        }
        
        func stub(_ url: URL, _ task: SessionDataTask = FakeURLSessionDataTask(), _ error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> SessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
    }
    
    private class FakeURLSessionDataTask: SessionDataTask {
        func resume() {
            
        }
    }
    private class URLSessionDataTaskSpy: SessionDataTask {
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
        
}
