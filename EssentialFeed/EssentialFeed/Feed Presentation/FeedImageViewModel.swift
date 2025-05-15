//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/15/25.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public var image: Image?
    public var description: String?
    public var location: String?
    public var url: URL
    public var isLoading: Bool
    public var shouldRetry: Bool
    
    public var hasLocation: Bool {
        (location != nil)
    }
}
