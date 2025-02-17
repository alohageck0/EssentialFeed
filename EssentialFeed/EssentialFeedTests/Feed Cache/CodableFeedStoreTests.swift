//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/6/25.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStore {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        
        tearDownEmptyStoreState()
    }

    func test_retreive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetreive: .empty)
    }
    
    func test_retreive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetreiveTwice: .empty)
    }
    
    func test_retreiveFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let expectedFeed = uniqueImageFeed().local
        let expectedTimeStamp = Date()
        
        insert((expectedFeed, expectedTimeStamp), to: sut)
        
        expect(sut, toRetreive: .found(feed: expectedFeed, timestamp: expectedTimeStamp))
    }
    
    func test_retreive_hasNoSideEffectsOnNonEmptyCache() {
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
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to be inserted successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimeStamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
    }
    
    func test_insert_overridesPrevouslyInsertedCachedValues() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        insert((latestFeed, latestTimeStamp), to: sut)
        
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
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeUrl: invalidStoreURL)
        let expectedFeed = uniqueImageFeed().local
        let expectedTimeStamp = Date()
        
        insert((expectedFeed, expectedTimeStamp), to: sut)
        
        expect(sut, toRetreive: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
         
        expect(sut, toRetreive: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetreive: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionsURL = cachesDirectory()
        let sut = makeSUT(storeUrl: noDeletePermissionsURL)
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionsURL = cachesDirectory()
        let sut = makeSUT(storeUrl: noDeletePermissionsURL)
        
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetreive: .empty)
    }
    
    func test_storeSideEffectsRunSerially() {
        let sut = makeSUT()
        
        var operations = [XCTestExpectation]()
        let op1 = expectation(description: "Complete first operation")
        sut.insert(uniqueImageFeed().local, Date()) { _ in
            operations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Complete second operation")
        sut.deleteCachedFeed { _ in
            operations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Complete third operation")
        sut.insert(uniqueImageFeed().local, Date()) { _ in
            operations.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 3.0)
        
        XCTAssertEqual(operations, [op1, op2, op3], "Expected side-effects to run serially, but operations finished in the wrong order ")
    }
    
    //MARK: Helpers
    
    private func makeSUT(storeUrl: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeUrl ?? testSpecificStoreURL())
        trackForMemeoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ expected: (feed: [LocalFeedImage], currentDate: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for retreival to complete")
        var insertionError: Error?
        sut.insert(expected.feed, expected.currentDate) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for deletion to complete")
        var deletionError: Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deletionError
    }
    
    private func expect(_ sut: FeedStore, toRetreive expectedResult: RetreiveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        
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
    
    private func expect(_ sut: FeedStore, toRetreiveTwice expectedResult: RetreiveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
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
