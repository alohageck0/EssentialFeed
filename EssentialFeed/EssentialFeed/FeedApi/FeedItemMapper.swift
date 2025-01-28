//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 12/31/24.
//

import Foundation

struct FeedItemMapper {
    struct Root: Decodable {
        public let items: [RemoteFeedItem]
    }
    
    private static var OK_200_status = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200_status, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
