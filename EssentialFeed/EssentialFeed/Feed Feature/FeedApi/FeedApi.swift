//
//  FeedApi.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 12/24/24.
//

import Foundation

public struct RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if let items = try? FeedItemMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        if let items = try? FeedItemMapper.map(data, response) {
            return .success(items)
        } else {
            return .failure(.invalidData)
        }
    }
}
