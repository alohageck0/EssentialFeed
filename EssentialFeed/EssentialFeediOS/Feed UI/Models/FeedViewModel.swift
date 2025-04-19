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
        case loaded([FeedImage])
        case failed
    }
    
    private var state = State.pending {
        didSet {
            onChange?(self)
        }
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    
    var isLoading: Bool {
        switch state {
        case .loading: true
        case .pending, .loaded, .failed: false
        }
    }
    
    var feed: [FeedImage]? {
        switch state {
        case .loaded(let feed): feed
        case .pending, .loading, .failed: nil
        }
    }
    
    func loadFeed() {
        state = .loading
        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.state = .loaded(feed)
            } else {
                self?.state = .failed
            }
        }
    }
}
