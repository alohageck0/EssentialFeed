//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/30/25.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp currentDate: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timeStamp = currentDate
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
        
    }
    
    public func retreive(completion: @escaping RetreivalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CacheFeed(feed: $0.localFeed, timestamp: $0.timeStamp)
                }
            })
        }
    }
}
