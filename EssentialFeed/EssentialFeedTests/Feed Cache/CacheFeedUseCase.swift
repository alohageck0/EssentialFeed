//
//  CacheFeedUseCase.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 1/19/25.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    let store: FeedStore
    var currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed() { [unowned self] error in
            if error == nil {
                self.store.insert(items, self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], _ currentDate: Date, completion: @escaping DeletionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, currentDate))
    }
}

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
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() throws {
        let (feedStore, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        feedStore.completeDeletion(with: deletionError)
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsInsertionWithATimestampOnSuccessfulDeletion() throws {
        let timeStamp = Date()
        let (feedStore, sut) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items) { _ in }
        feedStore.completeDeletionSuccessfully()
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(items, timeStamp)])
    }
    
    func test_save_failsOnDeletionError() throws {
        let (feedStore, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save to complete")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        feedStore.completeDeletion(with: deletionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_failsOnInsertionError() throws {
        let (feedStore, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        let insertionError = anyNSError()
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save to complete")
        sut.save(items) { error in
            receivedError = error
            exp.fulfill()
        }
        feedStore.completeDeletionSuccessfully()
        feedStore.completeInsertion(with: insertionError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, insertionError)
        // Investigate Error enums for deletion and insertion errors
//        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }

    // MARK: Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStore, sut: LocalFeedLoader) {
        let feedStore = FeedStore()
        let sut = LocalFeedLoader(store: feedStore, currentDate: currentDate)
        trackForMemeoryLeaks(feedStore, file: file, line: line)
        trackForMemeoryLeaks(sut, file: file, line: line)
        return (feedStore, sut)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "http://a-url.com/")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "1", code: 1)
    }
}
