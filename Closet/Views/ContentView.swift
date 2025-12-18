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
    @State private var categoryToEdit: Category?
    
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
                    List {
                        // Smart Folders
                        Section {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                SmartFolderTile(title: "Inbox", icon: "tray", count: 0)
                                SmartFolderTile(title: "Saved", icon: "bookmark.fill", count: 0)
                                SmartFolderTile(title: "Wanted", icon: "heart.fill", count: 0)
                                SmartFolderTile(title: "Recently Deleted", icon: "trash", count: 0)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        // Categories
                        Section {
                            ForEach(categories) { category in
                                NavigationLink(value: category) {
                                    CategoryRow(category: category)
                                }
                                .contextMenu {
                                    Button {
                                        categoryToEdit = category
                                    } label: {
                                        Label("Edit Category", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        modelContext.delete(category)
                                    } label: {
                                        Label("Delete Category", systemImage: "trash")
                                    }
                                }
                            }
                        } header: {
                            Text("Categories")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .textCase(nil)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Closet")
            .navigationDestination(for: Category.self) { category in
                CollectionListView(category: category)
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategorySheet()
            }
            .sheet(item: $categoryToEdit) { category in
                EditCategorySheet(category: category)
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


// MARK: - Smart Folder Tile

struct SmartFolderTile: View {
    let title: String
    let icon: String
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
                
                Spacer()
                
                Text("\(count)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon ?? "folder.fill")
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.blue)
                .clipShape(Circle())
            
            Text(category.name)
            
            Spacer()
            
            Text("\(category.collections.count)")
                .foregroundStyle(.secondary)
        }
    }
}




// MARK: - Collection List View

struct CollectionListView: View {
    @Environment(\.modelContext) private var modelContext
    let category: Category
    
    @State private var showAddCollection = false
    @State private var collectionToEdit: Collection?
    
    var body: some View {
        Group {
            if category.collections.isEmpty {
                ContentUnavailableView(
                    "No Collections",
                    systemImage: "folder",
                    description: Text("Add a collection to organize items in \(category.name)")
                )
            } else {
                List {
                    ForEach(category.collections.sorted(by: { $0.sortOrder < $1.sortOrder })) { collection in
                        NavigationLink(value: collection) {
                            CollectionRow(collection: collection)
                        }
                        .contextMenu {
                            Button {
                                collectionToEdit = collection
                            } label: {
                                Label("Edit Collection", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                modelContext.delete(collection)
                            } label: {
                                Label("Delete Collection", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(category.name)
        .navigationDestination(for: Collection.self) { collection in
            ItemListView(collection: collection)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddCollection = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddCollection) {
            AddCollectionSheet(category: category)
        }
        .sheet(item: $collectionToEdit) { collection in
            EditCollectionSheet(collection: collection)
        }
    }
}

// MARK: - Collection Row

struct CollectionRow: View {
    let collection: Collection
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(.orange)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(collection.name)
                
                if let limit = collection.itemLimit {
                    Text("\(collection.ownedCount) / \(limit) owned")
                        .font(.caption)
                        .foregroundStyle(collection.isAtLimit ? .red : .secondary)
                } else {
                    Text("\(collection.items.count) items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Add Collection Sheet

struct AddCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let category: Category
    
    @State private var name = ""
    @State private var hasLimit = false
    @State private var itemLimit = 10
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Collection Name", text: $name)
                }
                
                Section {
                    Toggle("Set Item Limit", isOn: $hasLimit)
                    
                    if hasLimit {
                        Stepper("Limit: \(itemLimit)", value: $itemLimit, in: 1...100)
                    }
                } footer: {
                    Text("Limit how many items can be marked as \"owned\" in this collection.")
                }
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addCollection()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addCollection() {
        let collection = Collection(
            name: name,
            itemLimit: hasLimit ? itemLimit : nil,
            sortOrder: category.collections.count
        )
        collection.category = category
        modelContext.insert(collection)
        dismiss()
    }
}

// MARK: - Edit Collection Sheet

struct EditCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var collection: Collection
    
    @State private var name: String
    @State private var hasLimit: Bool
    @State private var itemLimit: Int
    
    init(collection: Collection) {
        self.collection = collection
        self._name = State(initialValue: collection.name)
        self._hasLimit = State(initialValue: collection.itemLimit != nil)
        self._itemLimit = State(initialValue: collection.itemLimit ?? 10)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Collection Name", text: $name)
                }
                
                Section {
                    Toggle("Set Item Limit", isOn: $hasLimit)
                    
                    if hasLimit {
                        Stepper("Limit: \(itemLimit)", value: $itemLimit, in: 1...100)
                    }
                } footer: {
                    Text("Limit how many items can be marked as \"owned\" in this collection.")
                }
            }
            .navigationTitle("Edit Collection")
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
        collection.name = name
        collection.itemLimit = hasLimit ? itemLimit : nil
        dismiss()
    }
}

// MARK: - Item List View (Placeholder)

struct ItemListView: View {
    let collection: Collection
    
    var body: some View {
        Text("Items in \(collection.name)")
            .navigationTitle(collection.name)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Collection.self, Item.self], inMemory: true)
}
