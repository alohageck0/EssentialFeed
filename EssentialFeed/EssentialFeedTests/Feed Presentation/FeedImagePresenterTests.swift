//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 5/15/25.
//

import XCTest
import EssentialFeed

public final class FeedImagePresenter {
    let view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                image: nil,
                description: model.description,
                location: model.location,
                url: model.url,
                isLoading: true,
                shouldRetry: false)
        )
    }
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewModel)
}

public struct FeedImageViewModel {
    var image: Any?
    var description: String?
    var location: String?
    var url: URL
    var isLoading: Bool
    var shouldRetry: Bool
    
    var hasLocation: Bool {
        (location != nil)
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessages() {
        let (_, viewSpy) = makeSUT()
        _ = FeedImagePresenter(view: viewSpy)
        
        XCTAssertTrue(viewSpy.messages.isEmpty, "Expected no messages to be sent")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, viewSpy) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingImageData(for: image)
        
        let message = viewSpy.messages.first
        XCTAssertEqual(viewSpy.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel]()
        
        func display(_ viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
    }
}
