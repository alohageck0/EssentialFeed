//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/14/25.
//

import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: .none)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessages() async throws {
        let (_, view) = makeSut()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages initially")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSut()
        
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }

    // MARK: Helpers
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(errorView: viewSpy)
        trackForMemoryLeaks(viewSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, viewSpy)
    }
    
    class ViewSpy: FeedErrorView {
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
    }
}
