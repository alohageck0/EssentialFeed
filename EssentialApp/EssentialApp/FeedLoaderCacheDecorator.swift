//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            // Preferable not to use the chain mapping for side-effects, following the program for now
            
//            if let feed = try? result.get() {
//                self?.cache.save(feed) { _ in }
//            }
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
