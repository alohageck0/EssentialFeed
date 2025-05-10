//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 5/10/25.
//

import EssentialFeed
import UIKit

final class FeedViewAdapter: FeedView {
    weak var controller: FeedViewController?
    let loader: FeedImageDataLoader

    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }

    func display(viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: loader)
            
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(object: view),
                imageTransformer: UIImage.init)
            return view
        }
    }
}
