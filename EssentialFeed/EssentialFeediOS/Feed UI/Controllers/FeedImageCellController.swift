//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 3/25/25.
//

import UIKit
import EssentialFeed

public class FeedImageViewModel {
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var onImageLoad: ((UIImage?) -> Void)?
    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onShouldRetryImageLoadStateChange: ((Bool) -> Void)?

    var description: String? {
        model.description
    }

    var location: String? {
        model.location
    }

    var hasLocation: Bool {
        (location != nil)
    }

    var url: URL {
        model.url
    }

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader.loadImageData(from: model.url) { [weak self] result in
            if let image = (try? result.get()).flatMap(UIImage.init) {
                self?.onImageLoad?(image)
            } else {
                self?.onShouldRetryImageLoadStateChange?(true)

            }
            self?.onImageLoadingStateChange?(false)
        }
    }

    func cancelLoad() {
        task?.cancel()
    }
}

public final class FeedImageCellController {
    private let viewModel: FeedImageViewModel

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.viewModel = FeedImageViewModel(model: model, imageLoader: imageLoader)
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.onRetry = viewModel.loadImageData

        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            if isLoading {
                cell?.feedImageContainer.startShimmering()
            } else {
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        viewModel.loadImageData()
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelLoad()
    }
}
