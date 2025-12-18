//
//  EditCategoryView.swift
//  Closet
//
//  Created by Nolan Gericke on 12/18/25.
//

import SwiftUI

struct EditCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var category: Category
    @State private var name: String = ""
    @State private var selectedIcon: String? = "folder.fill"
    
    init(category: Category) {
        self.category = category
        self._name = State(initialValue: category.name)
        self._selectedIcon = State(initialValue: category.icon ?? "folder.fill")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category Name", text: $name)
                }
                
                // Icon picker
                Section {
                    PickerGrid(items: IconCatalog.all, selection: $selectedIcon) { icon, isSelected in
                        IconCell(name: icon, isSelected: isSelected)
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    private func saveChanges() {
        category.name = name
        category.icon = selectedIcon
        dismiss()
    }
}


