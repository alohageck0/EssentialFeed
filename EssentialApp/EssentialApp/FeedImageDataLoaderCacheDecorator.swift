//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import Foundation
import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.saveIgnoringResult(data, for: url)
            }
            completion(result)
        }
    }
    
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}
