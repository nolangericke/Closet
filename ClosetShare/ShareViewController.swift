//
//  ShareViewController.swift
//  ClosetShare
//
//  Created by Nolan Gericke on 12/18/25.
//

import UIKit
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@objc(ShareViewController)
class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Extract shared content
        extractSharedContent { [weak self] url, title, imageData in
            // If we have a URL but no image, try to fetch OG image
            if let url = url, imageData == nil {
                self?.fetchOpenGraphImage(from: url) { ogImageData, ogTitle in
                    DispatchQueue.main.async {
                        self?.presentShareView(
                            url: url,
                            title: ogTitle ?? title,
                            imageData: ogImageData
                        )
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.presentShareView(url: url, title: title, imageData: imageData)
                }
            }
        }
    }
    
    private func fetchOpenGraphImage(from url: URL, completion: @escaping (Data?, String?) -> Void) {
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil, nil)
                return
            }
            
            // Extract og:image using multiple patterns
            var ogImageURLString: String?
            
            // Pattern 1: property="og:image" content="..."
            if let match = self.extractMetaContent(from: html, property: "og:image") {
                ogImageURLString = match
            }
            
            // Pattern 2: name="og:image" content="..."
            if ogImageURLString == nil, let match = self.extractMetaContent(from: html, name: "og:image") {
                ogImageURLString = match
            }
            
            // Pattern 3: Try twitter:image as fallback
            if ogImageURLString == nil, let match = self.extractMetaContent(from: html, property: "twitter:image") {
                ogImageURLString = match
            }
            if ogImageURLString == nil, let match = self.extractMetaContent(from: html, name: "twitter:image") {
                ogImageURLString = match
            }
            
            // Extract og:title
            var ogTitle: String?
            if let match = self.extractMetaContent(from: html, property: "og:title") {
                ogTitle = match
            }
            if ogTitle == nil, let match = self.extractMetaContent(from: html, name: "og:title") {
                ogTitle = match
            }
            
            // Decode HTML entities in title
            ogTitle = ogTitle?.replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&#39;", with: "'")
                .replacingOccurrences(of: "&lt;", with: "<")
                .replacingOccurrences(of: "&gt;", with: ">")
            
            // Fetch the image if found
            guard let urlString = ogImageURLString,
                  let imageURL = URL(string: urlString) else {
                completion(nil, ogTitle)
                return
            }
            
            var imageRequest = URLRequest(url: imageURL)
            imageRequest.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
            
            let imageTask = URLSession.shared.dataTask(with: imageRequest) { imageData, _, _ in
                // Compress the image if it's too large
                if let imageData = imageData,
                   let uiImage = UIImage(data: imageData) {
                    let compressedData = uiImage.jpegData(compressionQuality: 0.7)
                    completion(compressedData, ogTitle)
                } else {
                    completion(imageData, ogTitle)
                }
            }
            imageTask.resume()
        }
        task.resume()
    }
    
    private func extractMetaContent(from html: String, property: String) -> String? {
        // Match: <meta property="og:image" content="...">
        let pattern = "<meta[^>]+property=[\"']\(property)[\"'][^>]+content=[\"']([^\"']+)[\"']"
        if let range = html.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
            let match = String(html[range])
            if let contentRange = match.range(of: "content=[\"']([^\"']+)[\"']", options: [.regularExpression, .caseInsensitive]) {
                var content = String(match[contentRange])
                content = content.replacingOccurrences(of: "content=", with: "")
                content = content.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                return content
            }
        }
        
        // Also try reversed order: content before property
        let pattern2 = "<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+property=[\"']\(property)[\"']"
        if let range = html.range(of: pattern2, options: [.regularExpression, .caseInsensitive]) {
            let match = String(html[range])
            if let contentRange = match.range(of: "content=[\"']([^\"']+)[\"']", options: [.regularExpression, .caseInsensitive]) {
                var content = String(match[contentRange])
                content = content.replacingOccurrences(of: "content=", with: "")
                content = content.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                return content
            }
        }
        
        return nil
    }
    
    private func extractMetaContent(from html: String, name: String) -> String? {
        // Match: <meta name="og:image" content="...">
        let pattern = "<meta[^>]+name=[\"']\(name)[\"'][^>]+content=[\"']([^\"']+)[\"']"
        if let range = html.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
            let match = String(html[range])
            if let contentRange = match.range(of: "content=[\"']([^\"']+)[\"']", options: [.regularExpression, .caseInsensitive]) {
                var content = String(match[contentRange])
                content = content.replacingOccurrences(of: "content=", with: "")
                content = content.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                return content
            }
        }
        
        // Also try reversed order
        let pattern2 = "<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+name=[\"']\(name)[\"']"
        if let range = html.range(of: pattern2, options: [.regularExpression, .caseInsensitive]) {
            let match = String(html[range])
            if let contentRange = match.range(of: "content=[\"']([^\"']+)[\"']", options: [.regularExpression, .caseInsensitive]) {
                var content = String(match[contentRange])
                content = content.replacingOccurrences(of: "content=", with: "")
                content = content.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                return content
            }
        }
        
        return nil
    }
    
    private func presentShareView(url: URL?, title: String?, imageData: Data?) {
        // Create the SwiftUI view
        let shareView = ShareExtensionView(
            sharedURL: url,
            sharedTitle: title ?? "New Item",
            sharedImageData: imageData,
            onSave: { [weak self] in
                self?.close()
            },
            onCancel: { [weak self] in
                self?.close()
            }
        )
        
        // Wrap in hosting controller
        let hostingController = UIHostingController(rootView: shareView)
        hostingController.view.backgroundColor = .clear
        
        // Add as child
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    private func extractSharedContent(completion: @escaping (URL?, String?, Data?) -> Void) {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completion(nil, nil, nil)
            return
        }
        
        var foundURL: URL?
        var foundTitle: String?
        var foundImageData: Data?
        
        let group = DispatchGroup()
        
        for item in extensionItems {
            // Get attributed title if available
            if let attributedTitle = item.attributedContentText {
                foundTitle = attributedTitle.string
            }
            
            guard let attachments = item.attachments else { continue }
            
            for attachment in attachments {
                // Check for URL
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, error in
                        if let url = item as? URL {
                            foundURL = url
                        }
                        group.leave()
                    }
                }
                
                // Check for plain text URL
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, error in
                        if let text = item as? String, let url = URL(string: text), url.scheme != nil {
                            foundURL = foundURL ?? url
                        }
                        group.leave()
                    }
                }
                
                // Check for image
                if attachment.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                        if let imageURL = item as? URL,
                           let data = try? Data(contentsOf: imageURL) {
                            foundImageData = data
                        } else if let image = item as? UIImage {
                            foundImageData = image.jpegData(compressionQuality: 0.8)
                        } else if let data = item as? Data {
                            foundImageData = data
                        }
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(foundURL, foundTitle, foundImageData)
        }
    }
    
    private func close() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}

// MARK: - Share Extension SwiftUI View

struct ShareExtensionView: View {
    let sharedURL: URL?
    let sharedTitle: String
    let sharedImageData: Data?
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var itemName: String
    @State private var selectedCategory: Category?
    @State private var selectedCollection: Collection?
    @State private var selectedStatus: ItemStatus = .saved
    @State private var notes: String = ""
    
    @State private var categories: [Category] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let modelContainer: ModelContainer?
    
    init(sharedURL: URL?, sharedTitle: String, sharedImageData: Data?, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.sharedURL = sharedURL
        self.sharedTitle = sharedTitle
        self.sharedImageData = sharedImageData
        self.onSave = onSave
        self.onCancel = onCancel
        self._itemName = State(initialValue: sharedTitle)
        
        // Initialize SwiftData container with shared App Group
        do {
            let schema = Schema([Category.self, Collection.self, Item.self])
            
            guard let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.nolangericke.closet"
            ) else {
                self.modelContainer = nil
                return
            }
            
            let storeURL = containerURL.appendingPathComponent("Closet.sqlite")
            let config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
            self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            self.modelContainer = nil
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if let error = errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if categories.isEmpty {
                    ContentUnavailableView(
                        "No Categories",
                        systemImage: "folder",
                        description: Text("Create a category in the Closet app first")
                    )
                } else {
                    Form {
                        // Preview section
                        Section {
                            HStack(spacing: 12) {
                                // Image preview
                                if let imageData = sharedImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Image(systemName: "link")
                                                .foregroundStyle(.secondary)
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    TextField("Item Name", text: $itemName)
                                        .font(.headline)
                                    
                                    if let url = sharedURL {
                                        Text(url.host ?? url.absoluteString)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        
                        // Category & Collection
                        Section {
                            Picker("Category", selection: $selectedCategory) {
                                Text("Select Category").tag(nil as Category?)
                                ForEach(categories) { category in
                                    Text(category.name).tag(category as Category?)
                                }
                            }
                            
                            if let category = selectedCategory {
                                Picker("Collection", selection: $selectedCollection) {
                                    Text("Select Collection").tag(nil as Collection?)
                                    ForEach(category.collections) { collection in
                                        Text(collection.name).tag(collection as Collection?)
                                    }
                                }
                            }
                        }
                        
                        // Status
                        Section {
                            Picker("Status", selection: $selectedStatus) {
                                ForEach(ItemStatus.allCases, id: \.self) { status in
                                    Label(status.displayName, systemImage: status.icon)
                                        .tag(status)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Notes
                        Section("Notes (Optional)") {
                            TextField("Add notes...", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                        }
                    }
                }
            }
            .navigationTitle("Save to Closet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty || selectedCollection == nil)
                }
            }
        }
        .fontDesign(.rounded)
        .onAppear {
            loadCategories()
        }
    }
    
    private func loadCategories() {
        guard let container = modelContainer else {
            errorMessage = "Could not access shared data"
            isLoading = false
            return
        }
        
        do {
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.sortOrder)])
            categories = try context.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func saveItem() {
        guard let container = modelContainer,
              let selectedColl = selectedCollection else { return }
        
        let context = ModelContext(container)
        
        // Fetch the collection in this context by its ID
        let collectionID = selectedColl.persistentModelID
        guard let collection = context.model(for: collectionID) as? Collection else {
            errorMessage = "Could not find collection"
            return
        }
        
        // Check if at limit for owned status
        var finalStatus = selectedStatus
        if selectedStatus == .owned && collection.isAtLimit {
            finalStatus = .want
        }
        
        let item = Item(
            name: itemName,
            status: finalStatus,
            photo: sharedImageData,
            notes: notes.isEmpty ? nil : notes,
            link: sharedURL
        )
        item.collection = collection
        
        context.insert(item)
        
        do {
            try context.save()
            onSave()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}
