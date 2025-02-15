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
        
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        
        tearDownEmptyStoreState()
    }

    func test_retreive_deliversEmptyOnEmptyCache() throws {
        let sut = makeSUT()
        
        expect(sut, toRetreive: .empty)
    }
    
    func test_retreive_hasNoSideEffectsOnEmptyCache() throws {
        let sut = makeSUT()
        
        expect(sut, toRetreiveTwice: .empty)
    }
    
    func test_retreiveFoundValuesOnNonEmptyCache() throws {
        let sut = makeSUT()
        let expectedFeed = uniqueImageFeed().local
        let expectedTimeStamp = Date()
        
        insert((expectedFeed, expectedTimeStamp), to: sut)
        
        expect(sut, toRetreive: .found(feed: expectedFeed, timestamp: expectedTimeStamp))
    }
    
    func test_retreive_hasNoSideEffectsOnNonEmptyCache() throws {
        let sut = makeSUT()
        let expectedFeed = uniqueImageFeed().local
        let expectedTimeStamp = Date()
        
        insert((expectedFeed, expectedTimeStamp), to: sut)
        
        expect(sut, toRetreiveTwice: .found(feed: expectedFeed, timestamp: expectedTimeStamp))
    }
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let storeUrl = testSpecificStoreURL()
        let sut = CodableFeedStore(storeUrl)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func insert(_ expected: (feed: [LocalFeedImage], currentDate: Date), to sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for retreival to complete")
        sut.insert(expected.feed, expected.currentDate) { insertionError in
            XCTAssertNil(insertionError, "Expected to be inserted successfully")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetreive expectedResult: RetreiveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for retreival to complete")
        sut.retreive { result in
            switch (expectedResult, result) {
            case (.empty, .empty):
                break
            case let (.found(expectedFeed, expectedTimeStamp), .found(retreivedFeed, retreivedTimestamp)):
                XCTAssertEqual(expectedFeed, retreivedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimeStamp, retreivedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected retreiving \(expectedResult) but got \(result)")
            }
            exp.fulfill()
        }
    
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetreiveTwice expectedResult: RetreiveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetreive: expectedResult, file: file, line: line)
        expect(sut, toRetreive: expectedResult, file: file, line: line)
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func tearDownEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
