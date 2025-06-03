//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/3/25.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primaryLoader: FeedImageDataLoader
    let fallbackLoader: FeedImageDataLoader
    
    init(primaryLoader: FeedImageDataLoader, fallbackLoader: FeedImageDataLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        primaryLoader.loadImageData(from: url, completion)
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImages() {
        let primaryLoaderSpy = LoaderSpy()
        let fallbackLoaderSpy = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(
            primaryLoader: primaryLoaderSpy,
            fallbackLoader: fallbackLoaderSpy
        )
        
        XCTAssertTrue(primaryLoaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let primaryLoaderSpy = LoaderSpy()
        let fallbackLoaderSpy = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(
            primaryLoader: primaryLoaderSpy,
            fallbackLoader: fallbackLoaderSpy
        )
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoaderSpy.loadedURLs, [url], "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoaderSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    // MARK: Helpers
    
    func anyURL() -> URL {
        URL(string: "http://a-url.com/")!
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private class Task: FeedImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func loadImageData(from url: URL, _ completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }
}
