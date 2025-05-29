//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/29/25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Data?, Error>
    
    func insert(data: Data, forURL url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
