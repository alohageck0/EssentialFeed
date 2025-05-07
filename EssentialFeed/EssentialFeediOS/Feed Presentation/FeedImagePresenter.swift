//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 4/26/25.
//

import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                image: nil,
                description: model.description,
                location: model.location,
                url: model.url,
                isLoading: true,
                shouldRetry: false)
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(
            FeedImageViewModel(
                image: image,
                description: model.description,
                location: model.location,
                url: model.url,
                isLoading: false,
                shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                image: nil,
                description: model.description,
                location: model.location,
                url: model.url,
                isLoading: false,
                shouldRetry: true)
        )
    }
}
