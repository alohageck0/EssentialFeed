//
//  FeedApi.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 12/24/24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public struct RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
