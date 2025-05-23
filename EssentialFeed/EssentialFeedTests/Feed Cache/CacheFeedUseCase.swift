//
//  CacheFeedUseCase.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 1/19/25.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_doesNotMessageStoreUponCreation() throws {
        let (feedStore, _) = makeSUT()
        
        XCTAssertEqual(feedStore.receivedMessages, [])
    }
    
    func test_save_requestsToDeleteCacheWhileSavingNewItems() throws {
        let (feedStore, sut) = makeSUT()
        
        sut.save(uniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() throws {
        let (feedStore, sut) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().models) { _ in }
        feedStore.completeDeletion(with: deletionError)
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsInsertionWithATimestampOnSuccessfulDeletion() throws {
        let timeStamp = Date()
        let (feedStore, sut) = makeSUT(currentDate: { timeStamp })
        let feed = uniqueImageFeed()
        
        sut.save(feed.models) { _ in }
        feedStore.completeDeletionSuccessfully()
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() throws {
        let (feedStore, sut) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, items: uniqueImageFeed().models, toCompleteWithError: deletionError) {
            feedStore.completeDeletion(with: deletionError)
        }
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_failsOnInsertionError() throws {
        let (feedStore, sut) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, items: uniqueImageFeed().models, toCompleteWithError: insertionError) {
            feedStore.completeDeletionSuccessfully()
            feedStore.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccesfulCacheInsertion() throws {
        let timeStamp = Date()
        let (feedStore, sut) = makeSUT(currentDate: { timeStamp })
        let feed = uniqueImageFeed()
        
        expect(sut, items: feed.models, toCompleteWithError: nil) {
            feedStore.completeDeletionSuccessfully()
            feedStore.completeInsertionSuccessfully()
        }
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timeStamp)])
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        var sut: LocalFeedLoader?
        let feedStore = FeedStoreSpy()
        sut = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        
        var receivedError = [Error?]()
        sut?.save([uniqueImage()], completion: { receivedError.append($0 as? Error)
        })
        sut = nil
        
        feedStore.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedError.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        var sut: LocalFeedLoader?
        let feedStore = FeedStoreSpy()
        sut = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        
        var receivedError = [Error?]()
        sut?.save([uniqueImage()], completion: { receivedError.append($0 as? Error)
        })
        
        feedStore.completeDeletionSuccessfully()
        sut = nil
        feedStore.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedError.isEmpty)
    }

    // MARK: Helpers
    
    private func expect(_ sut: LocalFeedLoader, items: [FeedImage], toCompleteWithError expectedError: NSError?, when action: () -> Void) {
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save to complete")
        sut.save(items) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                receivedError = error
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let feedStore = FeedStoreSpy()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        trackForMemoryLeaks(feedStore, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (feedStore, sut)
    }
}
