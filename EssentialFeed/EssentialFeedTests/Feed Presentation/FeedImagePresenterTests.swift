//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/15/25.
//

import XCTest

final class FeedImagePresenter {
    
    init(view: Any) {
        
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessages() {
        let (_, viewSpy) = makeSUT()
        _ = FeedImagePresenter(view: viewSpy)
        
        XCTAssertEqual(viewSpy.messages, [], "Expected no messages to be sent")
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy {
        private(set) var messages = Set<String>()
    }
}
