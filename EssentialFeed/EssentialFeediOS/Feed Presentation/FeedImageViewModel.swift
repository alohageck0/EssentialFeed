//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 4/20/25.
//

import EssentialFeed

public struct FeedImageViewModel<Image> {
    var image: Image?
    var description: String?
    var location: String?
    var url: URL
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool {
        (location != nil)
    }
}
