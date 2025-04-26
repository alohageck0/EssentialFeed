//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 4/24/25.
//

import EssentialFeed

public struct FeedLoadingViewModel {
    let isLoading: Bool
}

public struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedPresenter {
    typealias Observer<T> = (T) -> Void
    
    private let loader: FeedLoader
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    var loadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
