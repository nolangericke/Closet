//
//  Category.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import Foundation
import SwiftData

@Model
final class Category {
    // MARK: - Properties
    
    var name: String // the name of this category
    var icon: String? // optional SF Symbol icon name (e.g. "tshirt", "house")
    var sortOrder: Int // order for manual sorting in lists
    var dateCreated: Date // when this category was created
    
    // MARK: - Relationships
    
    // The collections within this category
    // When a category is deleted, all its collections are also deleted
    @Relationship(deleteRule: .cascade, inverse: \Collection.category)
    var collections: [Collection]
    
    // MARK: - Initializer
    
    init(name: String, icon: String? = nil, sortOrder: Int = 0) {
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
        self.dateCreated = Date()
        self.collections = []
    }
}
