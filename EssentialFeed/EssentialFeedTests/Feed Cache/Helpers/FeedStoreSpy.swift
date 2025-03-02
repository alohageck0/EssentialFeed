//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 1/30/25.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    var rereivalCompletions = [RetreivalCompletion]()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retreive
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeRetreival(with error: Error, at index: Int = 0) {
        rereivalCompletions[index](.failure(error))
    }
    
    func completeWithEmptyCache(at index: Int = 0) {
        rereivalCompletions[index](.success(.none))
    }
    
    func completeRetreivalSuccessfully(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        rereivalCompletions[index](.success(CacheFeed(feed: feed, timestamp: timestamp)))
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping DeletionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, currentDate))
    }
    
    func retreive(completion: @escaping RetreivalCompletion) {
        rereivalCompletions.append(completion)
        receivedMessages.append(.retreive)
    }
}
