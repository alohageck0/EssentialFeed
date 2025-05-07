//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 5/6/25.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, _ completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
