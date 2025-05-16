//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/16/25.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(completion: ((FeedImageDataLoader.Result) -> Void)? = nil) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtureCompletions()
            wrapped?.cancel()
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func preventFurtureCompletions() {
            completion = nil
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion: completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
                guard self != nil else { return }
                
                switch result {
                case let .success((data, response)):
                    if !data.isEmpty && response.statusCode == 200 {
                        task.complete(with: .success(data))
                    } else {
                        task.complete(with: .failure(Error.invalidData))
                    }
                case let .failure(error):
                    task.complete(with: .failure(error))
                }
            }
        
        return task
    }
}
