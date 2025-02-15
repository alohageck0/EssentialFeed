//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/6/25.
//

import XCTest
import EssentialFeed

class CodableFeedStore: FeedStore {
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
    
    func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let codableFeed = feed.map { CodableFeedImage($0) }
            let encoded = try encoder.encode(Cache(feed: codableFeed, timeStamp: currentDate))
            try encoded.write(to: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    func retreive(completion: @escaping RetreivalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        do {
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.local, timestamp: cache.timeStamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeUrl.path) else {
            return completion(nil)
        }
        do {
            try FileManager.default.removeItem(at: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
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
    
    func test_retreive_deliversFailureOnRetreivalError() {
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeUrl: storeUrl)
        
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut, toRetreive: .failure(anyNSError()))
    }
    
    func test_retreive_hasNoSideEffectsOnRetreivalError() {
        let storeUrl = testSpecificStoreURL()
        let sut = makeSUT(storeUrl: storeUrl)
        
        try! "invalid data".write(to: storeUrl, atomically: false, encoding: .utf8)
        
        expect(sut, toRetreiveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPrevouslyInsertedCachedValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to be inserted successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimeStamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        
        expect(sut, toRetreive: .found(feed: latestFeed, timestamp: latestTimeStamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeUrl: invalidStoreURL)
        let expectedFeed = uniqueImageFeed().local
        let expectedTimeStamp = Date()
        
        let insertionError = insert((expectedFeed, expectedTimeStamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion fails with an error")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
         
        expect(sut, toRetreive: .empty)
    }
    
    func test_delete_emptiesPreviouslyinsertedCache() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
        
        expect(sut, toRetreive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionsURL = cachesDirectory()
        let sut = makeSUT(storeUrl: noDeletePermissionsURL)
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        
        expect(sut, toRetreive: .empty)
    }
    
    //MARK: Helpers
    
    private func makeSUT(storeUrl: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeUrl ?? testSpecificStoreURL())
        trackForMemeoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ expected: (feed: [LocalFeedImage], currentDate: Date), to sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for retreival to complete")
        var insertionError: Error?
        sut.insert(expected.feed, expected.currentDate) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    private func deleteCache(from sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "wait for deletion to complete")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
    
    private func expect(_ sut: CodableFeedStore, toRetreive expectedResult: RetreiveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for retreival to complete")
        sut.retreive { result in
            switch (expectedResult, result) {
            case (.empty, .empty), (.failure, .failure):
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
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
