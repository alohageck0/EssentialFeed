//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/16/25.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refresh()
    }
    
    @objc func load() {
        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    @objc func refresh() {
        refreshControl?.beginRefreshing()
    }
}
