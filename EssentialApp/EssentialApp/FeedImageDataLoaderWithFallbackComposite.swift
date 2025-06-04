//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primaryLoader: FeedImageDataLoader
    let fallbackLoader: FeedImageDataLoader
    
    public init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primaryLoader.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                task.wrapped = self?.fallbackLoader.loadImageData(from: url, completion)
            }
        }
        return task
    }
}
