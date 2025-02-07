//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/6/25.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        completion(.empty)
    }
}
final class CodableFeedStoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_retreive_deliversEmptyOnEmptyCache() throws {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for retreival to complete")
        sut.retreive { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, but gor \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
