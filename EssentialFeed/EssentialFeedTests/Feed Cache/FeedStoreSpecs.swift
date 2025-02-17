//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Evgenii Iavorovich on 2/16/25.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retreive_deliversEmptyOnEmptyCache()
    func test_retreive_hasNoSideEffectsOnEmptyCache()
    func test_retreiveFoundValuesOnNonEmptyCache()
    func test_retreive_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPrevouslyInsertedCachedValues()

    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_hasNoSideEffectsOnNonEmptyCache()

    func test_storeSideEffectsRunSerially()
}

protocol FailableRetreiveSpecs: FeedStoreSpecs {
    func test_retreive_deliversFailureOnRetreivalError()
    func test_retreive_hasNoSideEffectsOnRetreivalError()
}

protocol FailableInsertSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetreiveSpecs & FailableInsertSpecs & FailableDeleteSpecs
