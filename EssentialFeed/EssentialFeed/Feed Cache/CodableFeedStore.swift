//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 2/15/25.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var local: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ feedImage: LocalFeedImage) {
            self.id = feedImage.id
            self.description = feedImage.description
            self.location = feedImage.location
            self.url = feedImage.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private var storeUrl: URL
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)queue", qos: .userInitiated, attributes: .concurrent)
    
    public init(_ storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    public func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping InsertionCompletion) {
        let storeUrl = self.storeUrl
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let codableFeed = feed.map { CodableFeedImage($0) }
                let encoded = try encoder.encode(Cache(feed: codableFeed, timeStamp: currentDate))
                try encoded.write(to: storeUrl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retreive(completion: @escaping RetreivalCompletion) {
        let storeUrl = self.storeUrl
        queue.async {
            guard let data = try? Data(contentsOf: storeUrl) else {
                return completion(.empty)
            }
            let decoder = JSONDecoder()
            do {
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.local, timestamp: cache.timeStamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeUrl = self.storeUrl
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeUrl.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeUrl)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
