//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/29/25.
//

import Foundation

public final class LocalFeedImageDataLoader {
    let store: FeedImageDataStore
    
    public init(_ store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Swift.Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, _ completion: @escaping (SaveResult) -> Void) {
        store.insert(data: data, forURL: url) { _ in }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public typealias LoadResult = FeedImageDataLoader.Result
    private class LoadImageDataTask: FeedImageDataLoaderTask {
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping ((LoadResult) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: LoadResult) {
            completion?(result)
        }
        
        func cancel() {
            preventFutureCompletions()
        }
        
        func preventFutureCompletions() {
            completion = nil
        }
    }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL, _ completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion: completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                })
        }
        return task
    }
}
