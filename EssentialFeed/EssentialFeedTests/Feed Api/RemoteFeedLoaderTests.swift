//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 12/23/24.
//

import XCTest
import EssentialFeed
import Foundation

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestData() async throws {
        let (client, _) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_appendsUrl() {
        let (client, sut) = makeSUT()
        
        sut.load { _ in }
        XCTAssertTrue(client.requestedURLs.count == 1)
    }
    
    func test_load_executesTwice() {
        let (client, sut) = makeSUT()
        
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertTrue(client.requestedURLs.count == 2)
    }
    
    func test_load_deliversError() {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "", code: 1)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200() {
        let (client, sut) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let data = makeItemsJsonData([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200WithInvalidJson() {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJson = Data("invalid".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        })
    }
    
    func test_load_deliversNoItemsOn200WithEmpltyList() {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJson = makeItemsJsonData([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemsOn200WithValidJson() {
        let (client, sut) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://some-url.com")!)
        
        let item2 = makeItem(
            id: UUID(),
            description: "a desc",
            location: "a loc",
            imageURL: URL(string: "http://some2-url.com")!)
        
        expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
            let itemsData = makeItemsJsonData([item1.json, item2.json])
            
            client.complete(withStatusCode: 200, data: itemsData)
        }
    }
    
    func test_load_doesNotDeliverResultsAfterSUTInstanceWasDeallocated() {
        let client = HTTPClientSpy()
        let url = URL(string: "http://a-url.com")!
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        
        sut?.load() {
            capturedResults.append($0)
        }
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJsonData([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL)
        
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.url.absoluteString,
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJsonData(_ items: [[String: Any]]) -> Data {
        let json = [
            "items": items
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load complition")
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult)", file: file, line: line)
            }
        
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (HTTPClientSpy, RemoteFeedLoader) {
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (client, sut)
    }
}
