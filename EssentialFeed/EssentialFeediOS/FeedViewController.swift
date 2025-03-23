//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/16/25.
//

import Foundation
import EssentialFeed
import UIKit

public protocol FeedImageDateLoader {
    func loadImage(for url: URL)
    func cancelImageDataLoad(from url: URL)
}

public final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private(set) var imageLoader: FeedImageDateLoader?
    private var tableModel = [FeedImage]()
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageDateLoader) {
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
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
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.locationContainer.isHidden = (cellModel.location == nil)
        imageLoader?.loadImage(for: cellModel.url)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellModel = tableModel[indexPath.row]
        imageLoader?.cancelImageDataLoad(from: cellModel.url)
    }
    
    @objc func load() {
        loader?.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    @objc func refresh() {
        refreshControl?.beginRefreshing()
    }
}
