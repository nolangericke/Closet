//
//  Collection.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import Foundation
import SwiftData

@Model
final class Collection {
    // MARK: - Properties
    var name: String // the name of this collection (e.g. "Pants", "Kitchen Tools")
    
    // optional limit on how many items can be "owned" in this collection
    // nil means no limit
    var itemLimit: Int?
    
    // Order for manual sorting in lists
    var sortOrder: Int
    
    // When this collection was created
    var dateCreated: Date
    
    // MARK: - Relationships
    
    var category: Category?
    
    // The items in this collection
    // When a collection is deleted, all its items are also deleted
    @Relationship(deleteRule: .cascade, inverse: \Item.collection)
    var items: [Item]
    
    // MARK: - Computed Properties
    
    // Count of items with owned status
    var ownedCount: Int {
        items.filter { $0.status == .owned }.count
    }
    
    // Whether the collection has reached its limit for owned items
    // uses limit because since itemLimit is optional Swift won't let you do comparisons with an optional directly
    var isAtLimit: Bool {
        guard let limit = itemLimit else { return false }
        return ownedCount >= limit
    }
    
    // How many more items can be owned (nil if no limit)
    var remainingSlots: Int? {
        guard let limit = itemLimit else { return nil }
        return max(0, limit - ownedCount)
    }
    
    // MARK: - Initializer
    init(name: String, itemLimit: Int? = nil, sortOrder: Int = 0) {
        self.name = name
        self.itemLimit = itemLimit
        self.sortOrder = sortOrder
        self.dateCreated = Date()
        self.category = nil
        self.items = []
    }
}
