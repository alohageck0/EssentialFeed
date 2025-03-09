//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 3/9/25.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        loader?.load() { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let spy = LoaderSpy()
        _ = FeedViewController(loader: spy)
        
        XCTAssertEqual(spy.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let spy = LoaderSpy()
        let sut = FeedViewController(loader: spy)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
