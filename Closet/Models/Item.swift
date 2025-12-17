//
//  Item.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    // MARK: - Properties
    
    /// The name of this item (e.g., "Levi's 501 Jeans")
    var name: String
    
    /// Photo of the item stored as binary data
    @Attribute(.externalStorage)
    var photo: Data?
    
    /// Color of the item (e.g., "Blue", "Black")
    var color: String?
    
    /// Freeform notes about this item
    var notes: String?
    
    /// URL link to the product page
    var link: URL?
    
    /// Current status: saved, want, or owned
    var status: ItemStatus
    
    /// When this item was added
    var dateAdded: Date
    
    /// When this item was last modified
    var dateModified: Date
    
    // MARK: - Relationships
    
    /// The collection this item belongs to
    var collection: Collection?
    
    // MARK: - Initializer
    
    init(
        name: String,
        status: ItemStatus = .saved,
        photo: Data? = nil,
        color: String? = nil,
        notes: String? = nil,
        link: URL? = nil
    ) {
        self.name = name
        self.status = status
        self.photo = photo
        self.color = color
        self.notes = notes
        self.link = link
        self.dateAdded = Date()
        self.dateModified = Date()
        self.collection = nil
    }
    
    // MARK: - Methods
    
    /// Updates the dateModified timestamp
    func touch() {
        self.dateModified = Date()
    }
}
