//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/14/25.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {

    func test_init_doesNotSendMessages() async throws {
        let (_, view) = makeSut()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages initially")
    }

    // MARK: Helpers
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = FeedPresenter(view: viewSpy)
        trackForMemoryLeaks(viewSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, viewSpy)
    }
    
    class ViewSpy {
        var messages: [Any] = []
    }
}
