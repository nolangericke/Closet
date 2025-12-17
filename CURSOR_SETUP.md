# Cursor Setup Guide for Closet (iOS 26 SwiftUI + SwiftData)

This guide helps you set up Cursor IDE for optimal iOS development with SwiftUI and SwiftData.

---

## 1. Required Tools

### Xcode 26
- Download from the Mac App Store or [Apple Developer](https://developer.apple.com/xcode/)
- Required for iOS 26 SDK, simulators, and signing

### Homebrew Packages
```bash
# Swift LSP support for Cursor
brew install xcode-build-server

# Optional: Project generation if you prefer code-defined projects
brew install xcodegen
```

---

## 2. Cursor Extensions

Install these extensions in Cursor (Cmd+Shift+X):

1. **Swift** (sswg.swift-lang) - Swift language support
2. **CodeLLDB** - Debugging support for Swift
3. **SweetPad** - Build and run iOS projects from Cursor (optional but helpful)

---

## 3. Configure Swift LSP

The Swift Language Server Protocol provides autocomplete, go-to-definition, and error checking in Cursor.

### Generate Build Server Config
Run this command from your project root:

```bash
cd "/Users/nolangericke/Library/Mobile Documents/com~apple~CloudDocs/Second Brain/Projects/Closet"
xcode-build-server config -project Closet.xcodeproj -scheme Closet
```

This creates a `buildServer.json` file that tells SourceKit-LSP how to understand your project.

### Regenerate After Changes
Run this command again whenever you:
- Add new files to the project
- Change build settings
- Add new frameworks or packages

---

## 4. Documentation to Import into Cursor

### Option A: Add to Cursor Docs (@docs)
In Cursor, you can add documentation that the AI can reference. Go to **Cursor Settings > Features > Docs** and add:

1. **Apple SwiftUI Documentation**
   - URL: `https://developer.apple.com/documentation/swiftui`
   
2. **Apple SwiftData Documentation**
   - URL: `https://developer.apple.com/documentation/swiftdata`

3. **Swift Language Guide**
   - URL: `https://docs.swift.org/swift-book/documentation/the-swift-programming-language/`

4. **Apple Human Interface Guidelines**
   - URL: `https://developer.apple.com/design/human-interface-guidelines/`

### Option B: Download Offline Documentation
For better results, you can download and add specific documentation:

1. **WWDC 2025 Sample Code** - Download from Apple Developer and add to project
2. **SwiftUI Tutorials** - Apple's official tutorials have excellent patterns

---

## 5. Project Structure Recommendation

Organize your project for better AI understanding:

```
Closet/
├── App/
│   └── ClosetApp.swift          # App entry point
├── Models/
│   ├── Item.swift               # Main inventory item model
│   ├── Category.swift           # Category model
│   └── Tag.swift                # Tag model for labeling
├── Views/
│   ├── ContentView.swift        # Main tab/navigation view
│   ├── Items/
│   │   ├── ItemListView.swift
│   │   ├── ItemDetailView.swift
│   │   ├── ItemRow.swift
│   │   └── AddItemView.swift
│   ├── Categories/
│   │   └── CategoryListView.swift
│   └── Components/
│       ├── EmptyStateView.swift
│       └── SearchBar.swift
├── Services/
│   └── DataService.swift        # Optional: centralized data operations
├── Extensions/
│   └── Date+Extensions.swift
├── Assets.xcassets/
└── Info.plist
```

---

## 6. Workflow Tips

### Build & Run
- Use **Xcode** for building and running on simulator/device
- Or use **SweetPad extension** in Cursor to build without leaving the editor

### Hot Reload (Optional Advanced Setup)
For real-time preview updates, you can set up InjectionIII:
1. Download [InjectionIII](https://github.com/johnno1962/InjectionIII)
2. Add to Other Linker Flags: `-Xlinker -interposable`
3. This allows code changes to reflect instantly without rebuilding

### Previews
- SwiftUI Previews work best in Xcode
- Use Cursor for code editing, switch to Xcode for preview canvas

---

## 7. AI Usage Tips

### When Asking Cursor AI About Your Project

1. **Reference specific files**: "Look at `Item.swift` and suggest improvements"
2. **Provide context**: "I'm using SwiftData with iOS 26, create a view that..."
3. **Use @-mentions**: "@Item.swift add a computed property for display name"

### Effective Prompts

```
"Create a SwiftUI form view for adding new inventory items with 
name, quantity, and category picker. Use SwiftData patterns."

"Add search functionality to ItemListView using the @Query results"

"Create a Category model with a one-to-many relationship to Item"
```

---

## 8. Files Created by This Setup

- `.cursorrules` - Main project guidelines for AI
- `.cursor/rules/swiftdata-patterns.mdc` - SwiftData specific patterns
- `.cursor/rules/swiftui-components.mdc` - SwiftUI component patterns
- `CURSOR_SETUP.md` - This file

---

## 9. Quick Reference Commands

```bash
# Generate/regenerate LSP config
xcode-build-server config -project Closet.xcodeproj -scheme Closet

# Clean build folder (from Xcode menu or)
xcodebuild clean -project Closet.xcodeproj -scheme Closet

# Build from command line
xcodebuild build -project Closet.xcodeproj -scheme Closet -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Need Help?

- SwiftUI issues: Check Apple's [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- SwiftData issues: Check Apple's [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- Cursor issues: Check [Cursor Documentation](https://docs.cursor.com)

