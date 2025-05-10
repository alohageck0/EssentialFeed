//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 5/10/25.
//

import EssentialFeed

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    let feedLoader: FeedLoader
    var presenter: FeedPresenter?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak presenter] result in
            switch result {
            case .success(let feed):
                presenter?.didFinishLoadingFeed(with: feed)
            case .failure(let error):
                presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
