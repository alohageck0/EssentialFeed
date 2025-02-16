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
    
    // The completion handler can be invoked i nany thread.
    // Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    // The completion handler can be invoked i nany thread.
    // Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping InsertionCompletion)
    
    // The completion handler can be invoked i nany thread.
    // Clients are responsible to dispatch to appropriate threads, if needed.
    func retreive(completion: @escaping RetreivalCompletion)
}
