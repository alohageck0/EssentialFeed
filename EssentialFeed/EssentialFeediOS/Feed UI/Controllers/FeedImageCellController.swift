//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/25/25.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        self.cell = cell
        delegate.didRequestImage()
        return cell
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.descriptionLabel.text = viewModel.description
        cell?.locationLabel.text = viewModel.location
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.feedImageView.image = viewModel.image
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.onRetry = delegate.didRequestImage
    }
    
    func releaseCellForReuse() {
        cell = nil
    }
}
