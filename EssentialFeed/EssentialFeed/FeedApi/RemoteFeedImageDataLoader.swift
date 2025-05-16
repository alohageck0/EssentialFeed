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
        case connectivity
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
                
                task.complete(with: result
                    .mapError { _ in Error.connectivity }
                    .flatMap { (data, response) in
                        let isValidResponse = !data.isEmpty && response.statusCode == 200
                        return isValidResponse ? .success(data) : .failure(Error.invalidData)
                    })
            }
        
        return task
    }
}
