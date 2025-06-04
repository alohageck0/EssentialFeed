//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
    let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
