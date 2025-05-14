//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 5/14/25.
//

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(message: String) -> Self {
        FeedErrorViewModel(message: message)
    }
}
