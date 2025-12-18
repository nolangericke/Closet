import SwiftUI
import SwiftData

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var selectedIcon: String? = "folder.fill"
    
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
            icon: selectedIcon
        )
        modelContext.insert(category)
        dismiss()
    }
}

#Preview {
    AddCategorySheet()
        .modelContainer(for: Category.self, inMemory: true)
}
