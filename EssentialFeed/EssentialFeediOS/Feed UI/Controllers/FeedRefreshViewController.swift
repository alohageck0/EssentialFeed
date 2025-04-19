//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/25/25.
//

import UIKit
//import EssentialFeed

public final class FeedRefreshViewController: NSObject {
    private let viewModel: FeedViewModel
    public lazy var view = binded(with: UIRefreshControl())
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    func binded(with view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] vm in
            if vm.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }
}
