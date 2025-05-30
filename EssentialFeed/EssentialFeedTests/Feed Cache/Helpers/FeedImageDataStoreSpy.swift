//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/29/25.
//

import Foundation
import EssentialFeed

public class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retreive(forURL: URL)
        case insert(data: Data, forURL: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private var retreivalCompletions = [(FeedImageDataStore.RetreivalResult) -> Void]()
    private var insertionCompletions = [(FeedImageDataStore.InsertionResult) -> Void]()
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetreivalResult) -> Void) {
        receivedMessages.append(.retreive(forURL: url))
        retreivalCompletions.append(completion)
    }
    
    public func insert(data: Data, forURL url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, forURL: url))
        insertionCompletions.append(completion)
    }
    
    func completeRetreival(with error: Error, at index: Int = 0) {
        retreivalCompletions[index](.failure(error))
    }
    
    func completeRetreival(with data: Data? = nil, at index: Int = 0) {
        retreivalCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
