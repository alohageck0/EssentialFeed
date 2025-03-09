//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 3/9/25.
//

import XCTest

class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let spy = LoaderSpy()
        _ = FeedViewController(loader: spy)
        
        XCTAssertEqual(spy.loadCallCount, 0)
    }
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
