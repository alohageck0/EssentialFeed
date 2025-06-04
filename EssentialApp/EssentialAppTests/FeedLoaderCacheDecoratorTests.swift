//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import XCTest
import EssentialFeed

final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoadSuccess() {
        let feed = uniqueFeed()
        let (sut, _) = makeSUT(result: .success(feed))
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoadFailure() {
        let (sut, _) = makeSUT(result: .failure(anyNSError()))
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: Helpers
    
    private func makeSUT(result: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> (sut: FeedLoaderCacheDecorator, loader: FeedLoader) {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
}
