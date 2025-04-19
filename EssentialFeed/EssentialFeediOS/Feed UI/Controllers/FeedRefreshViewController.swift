//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/25/25.
//

import UIKit
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

public final class FeedRefreshViewController: NSObject {
    private let viewModel: FeedViewModel
    public lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        bind(view)
        return view
    }()
    
    init(loader: FeedLoader) {
        self.viewModel = FeedViewModel(loader: loader)
    }
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    func bind(_ view: UIRefreshControl) {
        viewModel.onChange = { [weak self] vm in
            if vm.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }

            if let feed = vm.feed {
                self?.onRefresh?(feed)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}
