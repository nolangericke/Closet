//
//  ContentView.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    
    @State private var searchText = ""
    @State private var showAddCategory = false
    
    var body: some View {
        NavigationStack {
            Group {
                if categories.isEmpty {
                    // Empty State
                    ContentUnavailableView(
                        "No Categories",
                        systemImage: "rectangle.stack",
                        description: Text("Tap rectangle stack to create your first category")
                    )
                } else {
                    // Category List
                    List {
                        Section {
                            ForEach(categories) { category in
                                NavigationLink(value: category) {
                                    CategoryRow(category: category)
                                }
                            }
                        } header: {
                            Text("Categories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Closet")
            .navigationDestination(for: Category.self) { category in
                CollectionListView(category: category)
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategorySheet()
            }
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Category", systemImage: "rectangle.stack.badge.plus") {
                        showAddCategory = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("More", systemImage: "ellipsis") {
                        print("Button tapped")
                    }
                }
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Item", systemImage: "plus") {
                        print("Button tapped")
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack {
            Image(systemName: category.icon ?? "folder.fill")
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(category.name)
            
            Spacer()
            
            Text("\(category.collections.count)")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Add Category Sheet

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var icon = "folder.fill"
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category Name", text: $name)
                }
                
                Section("Icon") {
                    TextField("SF Symbol Name", text: $icon)
                    
                    // Preview the icon
                    HStack {
                        Text("Preview:")
                        Spacer()
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addCategory() {
        let category = Category(
            name: name,
            icon: icon.isEmpty ? nil : icon
        )
        modelContext.insert(category)
        dismiss()
    }
}

// MARK: - Collection List View (Placeholder)

struct CollectionListView: View {
    let category: Category
    
    var body: some View {
        Text("Collections in \(category.name)")
            .navigationTitle(category.name)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Collection.self, Item.self], inMemory: true)
}
