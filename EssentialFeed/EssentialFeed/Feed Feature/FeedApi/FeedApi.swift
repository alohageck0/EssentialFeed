//
//  FeedApi.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 12/24/24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public struct RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void = {error in}) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
