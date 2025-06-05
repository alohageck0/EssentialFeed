//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private(set) var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    private var completions = [(FeedImageDataLoader.Result) -> Void]()
    
    func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        completions.append(completion)
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        completions[index](.success(data))
    }
}
