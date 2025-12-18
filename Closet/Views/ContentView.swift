//
//  ContentView.swift
//  Closet
//
//  Created by Nolan Gericke on 12/17/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    
    @State private var searchText = ""
    @State private var showAddCategory = false
    @State private var categoryToEdit: Category?
    @State private var refreshID = UUID()
    
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
        .id(refreshID)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh data when app becomes active (e.g., after using Share Extension)
                refreshID = UUID()
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
    @Environment(\.modelContext) private var modelContext
    let collection: Collection
    
    @State private var showAddItem = false
    @State private var itemToEdit: Item?
    
    var body: some View {
        Group {
            if collection.items.isEmpty {
                ContentUnavailableView(
                    "No Items",
                    systemImage: "tray",
                    description: Text("Add items to \(collection.name)")
                )
            } else {
                List {
                    // Show limit warning if at capacity
                    if collection.isAtLimit {
                        Section {
                            Label("Collection is at capacity", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    // Group items by status
                    let ownedItems = collection.items.filter { $0.status == .owned }
                    let wantItems = collection.items.filter { $0.status == .want }
                    let savedItems = collection.items.filter { $0.status == .saved }
                    
                    if !ownedItems.isEmpty {
                        Section("Owned") {
                            ForEach(ownedItems) { item in
                                ItemRow(item: item)
                                    .contextMenu {
                                        itemContextMenu(for: item)
                                    }
                            }
                        }
                    }
                    
                    if !wantItems.isEmpty {
                        Section("Want") {
                            ForEach(wantItems) { item in
                                ItemRow(item: item)
                                    .contextMenu {
                                        itemContextMenu(for: item)
                                    }
                            }
                        }
                    }
                    
                    if !savedItems.isEmpty {
                        Section("Saved") {
                            ForEach(savedItems) { item in
                                ItemRow(item: item)
                                    .contextMenu {
                                        itemContextMenu(for: item)
                                    }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(collection.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddItem = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemSheet(collection: collection)
        }
        .sheet(item: $itemToEdit) { item in
            EditItemSheet(item: item, collection: collection)
        }
    }
    
    @ViewBuilder
    private func itemContextMenu(for item: Item) -> some View {
        Button {
            itemToEdit = item
        } label: {
            Label("Edit Item", systemImage: "pencil")
        }
        
        Menu("Change Status") {
            ForEach(ItemStatus.allCases, id: \.self) { status in
                Button {
                    // Check if trying to mark as owned when at limit
                    if status == .owned && collection.isAtLimit && item.status != .owned {
                        // Already at limit, can't add more owned
                    } else {
                        item.status = status
                        item.touch()
                    }
                } label: {
                    Label(status.displayName, systemImage: status.icon)
                }
                .disabled(status == .owned && collection.isAtLimit && item.status != .owned)
            }
        }
        
        Button(role: .destructive) {
            modelContext.delete(item)
        } label: {
            Label("Delete Item", systemImage: "trash")
        }
    }
}

// MARK: - Item Row

struct ItemRow: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: 12) {
            // Photo or placeholder
            if let photoData = item.photo, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                
                HStack(spacing: 8) {
                    // Status badge
                    Label(item.status.displayName, systemImage: item.status.icon)
                        .font(.caption)
                        .foregroundStyle(statusColor(for: item.status))
                    
                    // Color if set
                    if let color = item.color, !color.isEmpty {
                        Text("• \(color)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Link indicator
            if item.link != nil {
                Image(systemName: "link")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func statusColor(for status: ItemStatus) -> Color {
        switch status {
        case .saved: return .orange
        case .want: return .red
        case .owned: return .green
        }
    }
}

// MARK: - Add Item Sheet

struct AddItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let collection: Collection
    
    @State private var name = ""
    @State private var color = ""
    @State private var notes = ""
    @State private var linkString = ""
    @State private var status: ItemStatus = .saved
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    
    private var canMarkAsOwned: Bool {
        !collection.isAtLimit || status == .owned
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Photo Section
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            if let photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.largeTitle)
                                    Text("Add Photo")
                                        .font(.caption)
                                }
                                .frame(width: 120, height: 120)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    
                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            selectedPhotoItem = nil
                            photoData = nil
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Item Name", text: $name)
                    TextField("Color (optional)", text: $color)
                }
                
                Section {
                    Picker("Status", selection: $status) {
                        ForEach(ItemStatus.allCases, id: \.self) { status in
                            Label(status.displayName, systemImage: status.icon)
                                .tag(status)
                        }
                    }
                    
                    if collection.isAtLimit && status != .owned {
                        Label("Collection at capacity for owned items", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Section {
                    TextField("Link (optional)", text: $linkString)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onChange(of: selectedPhotoItem) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
    }
    
    private func addItem() {
        // Prevent adding as owned if at limit
        let finalStatus = (status == .owned && collection.isAtLimit) ? .want : status
        
        let item = Item(
            name: name,
            status: finalStatus,
            photo: photoData,
            color: color.isEmpty ? nil : color,
            notes: notes.isEmpty ? nil : notes,
            link: URL(string: linkString)
        )
        item.collection = collection
        modelContext.insert(item)
        dismiss()
    }
}

// MARK: - Edit Item Sheet

struct EditItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: Item
    let collection: Collection
    
    @State private var name: String
    @State private var color: String
    @State private var notes: String
    @State private var linkString: String
    @State private var status: ItemStatus
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    
    init(item: Item, collection: Collection) {
        self.item = item
        self.collection = collection
        self._name = State(initialValue: item.name)
        self._color = State(initialValue: item.color ?? "")
        self._notes = State(initialValue: item.notes ?? "")
        self._linkString = State(initialValue: item.link?.absoluteString ?? "")
        self._status = State(initialValue: item.status)
        self._photoData = State(initialValue: item.photo)
    }
    
    private var canMarkAsOwned: Bool {
        !collection.isAtLimit || item.status == .owned
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Photo Section
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            if let photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.largeTitle)
                                    Text("Add Photo")
                                        .font(.caption)
                                }
                                .frame(width: 120, height: 120)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    
                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            selectedPhotoItem = nil
                            photoData = nil
                        }
                    }
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Item Name", text: $name)
                    TextField("Color (optional)", text: $color)
                }
                
                Section {
                    Picker("Status", selection: $status) {
                        ForEach(ItemStatus.allCases, id: \.self) { s in
                            Label(s.displayName, systemImage: s.icon)
                                .tag(s)
                        }
                    }
                    
                    if collection.isAtLimit && item.status != .owned && status == .owned {
                        Label("Collection at capacity", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                
                Section {
                    TextField("Link (optional)", text: $linkString)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Item")
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
            .onChange(of: selectedPhotoItem) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        item.name = name
        item.color = color.isEmpty ? nil : color
        item.notes = notes.isEmpty ? nil : notes
        item.link = URL(string: linkString)
        item.photo = photoData
        
        // Only change to owned if not at limit (or already owned)
        if status == .owned && collection.isAtLimit && item.status != .owned {
            // Can't change to owned, keep current
        } else {
            item.status = status
        }
        
        item.touch()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Category.self, Collection.self, Item.self], inMemory: true)
}
