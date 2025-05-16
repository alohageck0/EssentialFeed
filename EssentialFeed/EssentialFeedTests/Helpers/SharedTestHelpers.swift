//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/2/25.
//

import Foundation


func anyURL() -> URL {
    URL(string: "http://a-url.com/")!
}

func anyNSError() -> NSError {
    NSError(domain: "1", code: 1)
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func emptyData() -> Data {
    return Data()
}
