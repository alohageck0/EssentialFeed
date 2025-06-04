//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.cache.save((try? result.get()) ?? []) { _ in }
            completion(result)
        }
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
    
    func test_load_cachesLoadFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let cacheSpy = FeedCacheSpy()
        let (sut, _) = makeSUT(result: .success(feed), cache: cacheSpy)
        
        sut.load { _ in }
        
        XCTAssertEqual(cacheSpy.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }
    
    // MARK: Helpers
    
    private func makeSUT(result: FeedLoader.Result, cache: FeedCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedLoaderCacheDecorator, loader: FeedLoader) {
        let loader = FeedLoaderStub(result: result)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private class FeedCacheSpy: FeedCache {
        
        var messages = [Message]()
        
        enum Message: Equatable {
            case save([FeedImage])
        }
        func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
        
    }
}
