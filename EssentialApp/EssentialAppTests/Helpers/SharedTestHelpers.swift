//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Evgenii Iavorovich on 6/4/25.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://a-url.com/")!
}

func anyNSError() -> NSError {
    NSError(domain: "", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}
