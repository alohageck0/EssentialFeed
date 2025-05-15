//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/14/25.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(message: String) -> Self {
        FeedErrorViewModel(message: message)
    }
}

