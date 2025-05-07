//
//  FeedRefreshViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 5/6/25.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

extension FeedRefreshViewController {
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        view.allTargets.forEach { target in
            view.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        view = fake
    }
    
    class FakeRefreshControl: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool {
            _isRefreshing
        }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}
