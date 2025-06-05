//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, _ completion: @escaping (Result) -> Void)
}
