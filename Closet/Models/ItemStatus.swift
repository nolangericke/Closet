//
//  ItemStatus.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import Foundation

// The status of an item in a collection
enum ItemStatus: String, Codable, CaseIterable {
    case saved = "saved"
    case want = "want"
    case owned = "owned"
    
    // Display name for the UI
    var displayName: String {
        switch self {
        case .saved: return "Saved"
        case .want: return "Want"
        case .owned: return "Owned"
        }
    }
    
    // SF Symbol icon for each status
    var icon: String {
        switch self {
        case .saved: return "bookmark"
        case .want: return "heart"
        case .owned: return "checkmark"
        }
    }
}

