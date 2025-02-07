//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/6/25.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timeStamp: Date
    }
    
    private var storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timeStamp: currentDate))
        try! encoded.write(to: storeUrl)
        completion(nil)
    }
    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        return completion(.found(feed: cache.feed, timestamp: cache.timeStamp))
    }
}
final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeUrl)
    }

    override func tearDown() {
        super.tearDown()
        
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeUrl)
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
    
    func test_retreive_hasNoSideEffectsOnEmptyCache() throws {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "wait for retreival to complete")
        sut.retreive { firstResult in
            sut.retreive { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty twice, but got \(firstResult) and \(secondResult)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retreiveAfterInsertingOnEmptyCacheDeliversInsertedValues() throws {
        let sut = CodableFeedStore()
        let expectedFeed = uniqueImageFeed().local
        let expectedTimeStamp = Date()
        
        let exp = expectation(description: "wait for retreival to complete")
        sut.insert(expectedFeed, expectedTimeStamp) { insertionError in
            XCTAssertNil(insertionError, "Expected to be inserted successfully")
            
            sut.retreive { result in
                switch result {
                case let .found(feed, timeStamp):
                    XCTAssertEqual(expectedFeed, feed)
                    XCTAssertEqual(expectedTimeStamp, timeStamp)
                    
                default:
                    XCTFail("Expected feed \(expectedFeed) with timeStamp: \(expectedTimeStamp) but got \(result)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
