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
    
    var deleteCacheFeedCount = 0
    var insertCallCount = 0
    var deletionCompletions = [DeletionCompletion]()
    var insertions = [(items: [FeedItem], timeStamp: Date)]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCacheFeedCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], _ currentDate: Date) {
        insertCallCount += 1
        insertions.append((items, currentDate))
    }
}

final class CacheFeedUseCaseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_doesNotDeleteCacheUponCreation() throws {
        let (feedStore, _) = makeSUT()
        
        XCTAssertEqual(feedStore.deleteCacheFeedCount, 0)
    }
    
    func test_save_requestsToDeleteCacheWhileSavingNewItems() throws {
        let (feedStore, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(feedStore.deleteCacheFeedCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() throws {
        let (feedStore, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        feedStore.completeDeletion(with: deletionError)
        
        XCTAssertEqual(feedStore.insertCallCount, 0)
    }
    
    func test_save_requestsInsertionOnSuccessfulDeletion() throws {
        let (feedStore, sut) = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        feedStore.completeDeletionSuccessfully()
        
        XCTAssertEqual(feedStore.insertCallCount, 1)
    }
    
    func test_save_requestsInsertionWithATimestampOnSuccessfulDeletion() throws {
        let timeStamp = Date()
        let (feedStore, sut) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        feedStore.completeDeletionSuccessfully()
        
        XCTAssertEqual(feedStore.insertions.count, 1)
        XCTAssertEqual(feedStore.insertions.first?.items, items)
        XCTAssertEqual(feedStore.insertions.first?.timeStamp, timeStamp)
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
