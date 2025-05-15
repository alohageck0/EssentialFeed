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
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages initially")
    }

    // MARK: Helpers
    
    struct ViewSpy {
        var messages: [Any] = []
    }
}
