//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 4/19/25.
//

import EssentialFeed

public final class FeedViewModel {
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    enum State {
        case pending
        case loading
    }
    
    private var state = State.pending {
        didSet {
            onChange?(self)
        }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    var isLoading: Bool {
        switch state {
        case .loading: true
        case .pending: false
        }
    }
    
    func loadFeed() {
        state = .loading
        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.state = .pending
        }
    }
}
