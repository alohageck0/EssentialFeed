//
//  CacheFeedUseCase.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 1/19/25.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
    
    }
}

class FeedStore {
    var deleteCacheFeedCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_doesNotDeleteCacheUponCreation() throws {
        let feedStore = FeedStore()
        let _ = LocalFeedLoader(store: feedStore)
        
        XCTAssertEqual(feedStore.deleteCacheFeedCount, 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
