//
//  ManagedCache+CoreDataProperties.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 2/20/25.
//
//

import Foundation
import CoreData

@objc(ManagedCache)
public class ManagedCache: NSManagedObject {
    @NSManaged public var timeStamp: Date
    @NSManaged public var feed: NSOrderedSet

}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    @discardableResult
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
}
