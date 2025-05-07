//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/25/25.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    var delegate: FeedRefreshViewControllerDelegate?
    @IBOutlet public var view: UIRefreshControl?

    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
