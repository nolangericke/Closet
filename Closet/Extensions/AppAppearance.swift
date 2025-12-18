//
//  AppAppearance.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import SwiftUI

struct AppAppearance {
    static func configure() {
        // Large title (when scrolled to top)
        let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        if let roundedDescriptor = largeTitle.fontDescriptor.withDesign(.rounded) {
            let roundedLargeTitle = UIFont(descriptor: roundedDescriptor, size: 34)
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .font: roundedLargeTitle
            ]
        }
        
        // Inline title (when scrolled)
        let inlineTitle = UIFont.systemFont(ofSize: 17, weight: .semibold)
        if let roundedDescriptor = inlineTitle.fontDescriptor.withDesign(.rounded) {
            let roundedInlineTitle = UIFont(descriptor: roundedDescriptor, size: 17)
            UINavigationBar.appearance().titleTextAttributes = [
                .font: roundedInlineTitle
            ]
        }
    }
}
