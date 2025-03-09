//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 3/9/25.
//

import XCTest
import UIKit

final class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        loader?.load()
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
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}
