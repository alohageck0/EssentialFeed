//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/14/25.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: Self {
        FeedErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> Self {
        FeedErrorViewModel(message: message)
    }
}

