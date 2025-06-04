//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
