//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 1/26/25.
//

import Foundation

public enum RetreiveCacheResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetreivalCompletion = (RetreiveCacheResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping InsertionCompletion)
    func retreive(completion: @escaping RetreivalCompletion)
}
