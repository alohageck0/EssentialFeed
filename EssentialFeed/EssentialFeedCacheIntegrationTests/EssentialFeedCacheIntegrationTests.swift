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
        
        let exp = expectation(description: "Wait for load")
        sut.load { result in
            switch result {
            case let .success(items):
                XCTAssertEqual(items, [], "Expected feed to be empty")
            case .failure(let error):
                XCTFail("Expected successfull result, unexpected error: \(error)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let expectedImageFeed = uniqueImageFeed().models
        
        let saveExp = expectation(description: "Wait for save competion")
        sutToPerformSave.save(expectedImageFeed) { saveError in
            XCTAssertNil(saveError, "Expected to save successfully")
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1.0)
        
        let loadExp = expectation(description: "Wait for load competion")
        sutToPerformLoad.load { loadResult in
            switch loadResult {
            case let .success(receivedImageFeed):
                XCTAssertEqual(receivedImageFeed, expectedImageFeed, "Expected to load the feed")
            case .failure(let error):
                XCTFail("Expected successfull result, unexpected error: \(error)")
            }
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1.0)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeUrl = testSpecificStoreUrl()
        let feedStore = try! CoreDataFeedStore(storeUrl: storeUrl, bundle: storeBundle)
        let sut = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        trackForMemeoryLeaks(feedStore, file: file, line: line)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return sut
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
