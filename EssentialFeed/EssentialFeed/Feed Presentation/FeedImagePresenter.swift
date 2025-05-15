//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/15/25.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
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
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(
            FeedImageViewModel(
                image: image,
                description: model.description,
                location: model.location,
                url: model.url,
                isLoading: false,
                shouldRetry: image == nil)
        )
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
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
