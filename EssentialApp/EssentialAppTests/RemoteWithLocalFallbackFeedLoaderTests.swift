//
//  RemoteWithLocalFallbackFeedLoaderTests.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/2/25.
//

import XCTest
import EssentialFeed
import EssentialApp

struct FeedLoaderWithFallbackComposite: FeedLoader {
    let primary: FeedLoader
    let fallback: FeedLoader
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

class RemoteWithLocalFallbackFeedLoaderTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoaderStub = FeedLoaderStub(result: .success(primaryFeed))
        let fallbackLoaderStub = FeedLoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(
            primary: primaryLoaderStub,
            fallback: fallbackLoaderStub)
        
        let exp = expectation(description: "wait for load")
        sut.load { result in
            switch result {
            case .success(let receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Helpers
    
    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
    }
    
    private struct FeedLoaderStub: FeedLoader {
        let result: FeedLoader.Result
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
