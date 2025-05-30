//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Evgenii Iavorovich on 2/23/25.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()

        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let expectedImageFeed = uniqueImageFeed().models
        
        save(expectedImageFeed, with: sutToPerformSave)
        expect(sutToPerformLoad, toLoad: expectedImageFeed)
    }
    
    func test_save_overridesItemsSaveOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let lastFeed = uniqueImageFeed().models
        
        save(firstFeed, with: sutToPerformFirstSave)
        save(lastFeed, with: sutToPerformLastSave)
        expect(sutToPerformLoad, toLoad: lastFeed)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeUrl = testSpecificStoreUrl()
        let feedStore = try! CoreDataFeedStore(storeURL: storeUrl)
        let sut = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        trackForMemoryLeaks(feedStore, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        
        let saveExp = expectation(description: "Wait for save competion")
        sut.save(feed) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expected successfull result, unexpected error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load")
        sut.load { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items, feed, "Expected feed to be empty", file: file, line: line)
            case .failure(let error):
                XCTFail("Expected successfull result, unexpected error: \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreUrl())
    }
    
    private func testSpecificStoreUrl() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
