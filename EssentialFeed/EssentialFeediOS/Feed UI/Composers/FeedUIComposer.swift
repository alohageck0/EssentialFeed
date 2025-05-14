//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 4/11/25.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenterAdapter = FeedLoaderPresentationAdapter(
            feedLoader: MainQueueDispatchDecorator(decoratee: loader))
        
        let feedController = makeFeedViewController(
            delegate: presenterAdapter,
            title: FeedPresenter.title)
        
        presenterAdapter.presenter = FeedPresenter(
            loadingView: WeakRefVirtualProxy(object: feedController),
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            errorView: WeakRefVirtualProxy(object: feedController))
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
