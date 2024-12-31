//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 12/31/24.
//

import Foundation

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
    
    private static var OK_200_status = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200_status else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
