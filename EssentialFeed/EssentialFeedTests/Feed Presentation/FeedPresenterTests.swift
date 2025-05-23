//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/14/25.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }

    func test_init_doesNotSendMessages() async throws {
        let (_, view) = makeSut()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages initially")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessageAndDisplaysLoading() {
        let (sut, view) = makeSut()
        
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none),
            .display(isLoading: true)])
    }
    
    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSut()
        let feed = uniqueImageFeed().models
        
        sut.didFinishLoadingFeed(with: feed)
        XCTAssertEqual(view.messages, [.display(feed: feed),
            .display(isLoading: false)])
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorAndStopsLoading() {
        let (sut, view) = makeSut()
        let error = anyNSError()
        
        sut.didFinishLoadingFeed(with: error)
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
    }

    // MARK: Helpers
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(loadingView: viewSpy, feedView: viewSpy, errorView: viewSpy)
        trackForMemoryLeaks(viewSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, viewSpy)
    }
    
    class ViewSpy: FeedErrorView, FeedLoadingView, FeedView {
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }
        
        private(set) var messages = Set<Message>()
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
