//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 2/20/25.
//

import CoreData

final public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    
    public init (bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", in: bundle)
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], _ currentDate: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retreive(completion: @escaping RetreivalCompletion) {
        completion(.empty)
    }
}

extension ManagedCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }

    @NSManaged public var timeStamp: Date
    @NSManaged public var feed: NSOrderedSet

}

extension ManagedFeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeedImage> {
        return NSFetchRequest<ManagedFeedImage>(entityName: "ManagedFeedImage")
    }

    @NSManaged public var id: UUID
    @NSManaged public var imageDescription: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL
    @NSManaged public var cache: ManagedCache

}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else { throw LoadingError.modelNotFound }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0)
        }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
