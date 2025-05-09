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
    let loadingView: FeedLoadingView
    let feedView: FeedView
    
    init(loadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    static var title: String {
        return "My Feed"
    }
    
    func didStartLoadingFeed() {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
