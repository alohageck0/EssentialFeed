//
//  FeedViewControllerTests+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 5/9/25.
//

import EssentialFeediOS
import XCTest

extension FeedViewControllerTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
}
