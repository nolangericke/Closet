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
