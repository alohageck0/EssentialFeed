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
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed() { [unowned self] error in
            if error == nil {
                self.store.insert(items, self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deletionCompletions = [DeletionCompletion]()
    var insertions = [(items: [FeedItem], timeStamp: Date)]()
    
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
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], _ currentDate: Date) {
        insertions.append((items, currentDate))
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
        sut.save(items)
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() throws {
        let (feedStore, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        feedStore.completeDeletion(with: deletionError)
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsInsertionWithATimestampOnSuccessfulDeletion() throws {
        let timeStamp = Date()
        let (feedStore, sut) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        feedStore.completeDeletionSuccessfully()
        
        XCTAssertEqual(feedStore.receivedMessages, [.deleteCachedFeed, .insert(items, timeStamp)])
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
