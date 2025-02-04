//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 2/3/25.
//

import Foundation

internal struct FeedCachePolicy {
    private init() {}
    static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int { 7 }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxAgeCache = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false
        }
        return date < maxAgeCache
    }
}
