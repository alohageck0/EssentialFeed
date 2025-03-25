//
//  FeedImageDateLoader.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/25/25.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}
public protocol FeedImageDateLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, _ completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
