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
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var local: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ feedImage: LocalFeedImage) {
            self.id = feedImage.id
            self.description = feedImage.description
            self.location = feedImage.location
            self.url = feedImage.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private var storeUrl: URL
    
    init(_ storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let codableFeed = feed.map { CodableFeedImage($0) }
        let encoded = try! encoder.encode(Cache(feed: codableFeed, timeStamp: currentDate))
        try! encoded.write(to: storeUrl)
        completion(nil)
    }
    func retreive(completion: @escaping FeedStore.RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        return completion(.found(feed: cache.local, timestamp: cache.timeStamp))
    }
}
final class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    func test_retreive_deliversEmptyOnEmptyCache() throws {
        let sut = makeSUT()
        
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
        let sut = makeSUT()
        
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
        let sut = makeSUT()
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
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let storeUrl = testSpecificStoreURL()
        let sut = CodableFeedStore(storeUrl)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
