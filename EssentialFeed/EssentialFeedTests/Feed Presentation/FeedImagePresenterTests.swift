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
    private let imageTransformer: (Data) -> Any?
    
    init(view: FeedImageView, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
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
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        view.display(
            FeedImageViewModel(
                image: imageTransformer(data),
                description: model.description,
                location: model.location,
                url: model.url,
                isLoading: false,
                shouldRetry: true)
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
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, viewSpy) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = viewSpy.messages.first
        XCTAssertEqual(viewSpy.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    // MARK: Helpers
    
    private func makeSUT(imageTransformer: @escaping (Data) -> Any? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private var fail: (Data) -> Any? {
        { _ in nil }
    }
    
    private class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewModel]()
        
        func display(_ viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
    }
}
