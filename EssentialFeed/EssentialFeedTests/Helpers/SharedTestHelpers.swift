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
