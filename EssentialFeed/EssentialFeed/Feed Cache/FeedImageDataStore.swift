//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/29/25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
