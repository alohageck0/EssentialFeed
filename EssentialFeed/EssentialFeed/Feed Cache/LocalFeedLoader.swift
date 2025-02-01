//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 1/26/25.
//

import Foundation

public class LocalFeedLoader {
    let store: FeedStore
    var currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                completion(error)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retreive { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
            case .empty, .found:
                completion(.success([]))
            }
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxAgeCache = calendar.date(byAdding: .day, value: 7, to: timestamp) else { return false
        }
        return currentDate() < maxAgeCache
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        self.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
