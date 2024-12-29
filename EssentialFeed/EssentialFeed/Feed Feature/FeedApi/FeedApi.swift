//
//  FeedApi.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 12/24/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
    
    struct FeedItemMapper {
        struct Root: Decodable {
            public let items: [Item]
        }
        
        struct Item: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
            
            var item: FeedItem {
                FeedItem(id: id, description: description, location: location, imageURL: image)
            }
        }
        
        static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
            guard response.statusCode == 200 else {
                throw Error.invalidData
            }
            return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
        }
    }
}
