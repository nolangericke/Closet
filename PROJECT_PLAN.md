# Closet - Project Plan

> A mindful consumption app for tracking wardrobe and household items

---

## 🎯 Core Problem

Reduce decision fatigue and overbuying by:
1. Knowing what you already own
2. Setting intentional limits per category
3. Organizing potential purchases into a clear pipeline (idea → wishlist → bought)

---

## 📱 Platform

- **iPhone only** (iOS 26+)
- SwiftUI + SwiftData

---

## 🗂️ Data Structure

```
📁 General Category (e.g., "Clothing", "Home")
│
└── 📂 Subcategory (e.g., "Pants", "Kitchen Tools")
    │   └── Optional quantity limit (e.g., max 5)
    │
    ├── 📦 Item (e.g., "Hollister Jeans")
    │       ├── Status: bought | wishlist | idea
    │       ├── Name
    │       ├── Photo
    │       ├── Color
    │       ├── Notes
    │       └── Link (URL)
    │
    └── 📦 Item ...
```

### Status Rules
| Status | Counts Toward Limit | Can Add Freely |
|--------|---------------------|----------------|
| Idea | ❌ No | ✅ Yes |
| Wishlist | ❌ No | ✅ Yes |
| Bought | ✅ Yes | 🚫 Blocked if at limit |

---

## 🧩 Data Models

### GeneralCategory
| Property | Type | Notes |
|----------|------|-------|
| id | UUID | Primary key |
| name | String | e.g., "Clothing" |
| icon | String? | SF Symbol name (optional) |
| subcategories | [Subcategory] | Relationship |
| sortOrder | Int | For manual ordering |

### Subcategory
| Property | Type | Notes |
|----------|------|-------|
| id | UUID | Primary key |
| name | String | e.g., "Pants" |
| itemLimit | Int? | Optional cap (nil = unlimited) |
| generalCategory | GeneralCategory | Parent relationship |
| items | [Item] | Relationship |
| sortOrder | Int | For manual ordering |

### Item
| Property | Type | Notes |
|----------|------|-------|
| id | UUID | Primary key |
| name | String | Item name |
| photo | Data? | Stored image |
| color | String? | e.g., "Blue" |
| notes | String? | Freeform text |
| link | URL? | Product URL |
| status | ItemStatus | bought/wishlist/idea |
| subcategory | Subcategory | Parent relationship |
| dateAdded | Date | Auto-set |
| dateModified | Date | Auto-updated |

### ItemStatus (Enum)
```swift
enum ItemStatus: String, Codable {
    case idea
    case wishlist
    case bought
}
```

---

## 📲 Navigation Structure

```
┌─────────────────────────────────────┐
│            Tab Bar                  │
├───────────┬───────────┬─────────────┤
│   Home    │  Wishlist │  Settings   │
│    🏠     │     💫    │     ⚙️      │
└───────────┴───────────┴─────────────┘
```

### Home Tab (🏠)
- Grid/list of General Categories
- Tap category → see Subcategories
- Tap subcategory → see Items (grouped by status)
- Shows limit progress (e.g., "3/5 pants")

### Wishlist Tab (💫)
- All wishlist items across all categories
- Grouped by subcategory or flat list
- Quick actions: move to bought, move to idea, delete

### Settings Tab (⚙️)
- Manage categories
- App preferences
- Future: Reminders sync settings

---

## ✨ Key Features

### Phase 1: Core (MVP)
- [ ] Create/edit/delete General Categories
- [ ] Create/edit/delete Subcategories with optional limits
- [ ] Create/edit/delete Items with all properties
- [ ] Photo picker for items
- [ ] Status management (idea → wishlist → bought)
- [ ] Limit enforcement (block marking as bought if at limit)
- [ ] Home tab with category browsing
- [ ] Wishlist tab (cross-category view)
- [ ] Basic settings

### Phase 2: Share Extension
- [ ] Safari Share Sheet integration
- [ ] Auto-extract page title as item name
- [ ] Auto-extract og:image as photo
- [ ] Auto-save URL as link
- [ ] Quick subcategory picker in share sheet

### Phase 3: Enhancements
- [ ] Search across all items
- [ ] Apple Reminders two-way sync
- [ ] iCloud sync (via SwiftData + CloudKit)
- [ ] Widgets (wishlist count, limit status)

---

## 🎨 Visual Design

**Style:** Clean & Minimal

### Design Principles
- Generous white space
- Simple typography (SF Pro)
- Subtle colors, not overwhelming
- Photos as the visual focus
- Clear visual hierarchy

### Color Palette
- Background: System background (adapts to light/dark)
- Accent: Soft, muted tone (e.g., sage green, dusty blue)
- Status indicators:
  - Idea: Gray
  - Wishlist: Accent color
  - Bought: Green checkmark

### Component Patterns
- Cards with rounded corners for items
- Progress bars for limit tracking
- Subtle shadows/depth
- Standard iOS navigation patterns

---

## 🔧 Technical Architecture

### Frameworks
- **SwiftUI** - UI
- **SwiftData** - Persistence
- **PhotosUI** - Photo picker
- **EventKit** - Reminders (Phase 3)
- **LinkPresentation** - URL metadata extraction (Share Extension)

### File Structure
```
Closet/
├── App/
│   └── ClosetApp.swift
├── Models/
│   ├── GeneralCategory.swift
│   ├── Subcategory.swift
│   ├── Item.swift
│   └── ItemStatus.swift
├── Views/
│   ├── ContentView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── CategoryGridView.swift
│   │   ├── SubcategoryListView.swift
│   │   └── ItemListView.swift
│   ├── Wishlist/
│   │   └── WishlistView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   ├── Items/
│   │   ├── ItemDetailView.swift
│   │   ├── ItemRow.swift
│   │   └── AddItemView.swift
│   └── Components/
│       ├── LimitProgressView.swift
│       ├── StatusPicker.swift
│       └── PhotoPickerView.swift
├── Extensions/
├── Services/
│   └── MetadataService.swift (URL parsing)
└── ShareExtension/
    └── ShareViewController.swift
```

---

## 📋 Development Order

### Sprint 1: Foundation
1. Set up data models (GeneralCategory, Subcategory, Item)
2. Create basic CRUD for categories
3. Build Home tab navigation (categories → subcategories → items)

### Sprint 2: Items
4. Item creation form with photo picker
5. Item detail view
6. Status management with limit enforcement
7. Edit and delete items

### Sprint 3: Wishlist & Polish
8. Wishlist tab (cross-category view)
9. Settings tab
10. UI polish and empty states
11. Swipe actions and context menus

### Sprint 4: Share Extension
12. Create Share Extension target
13. URL metadata extraction
14. Share sheet UI
15. Saving to main app

### Sprint 5: Enhancements
16. Search
17. Reminders integration
18. CloudKit sync

---

## 🚀 Success Metrics

- Can quickly add items from Safari
- Clear visibility into what you own per category
- Limits actually prevent overbuying
- Enjoyable to browse your inventory

---

## 📝 Notes & Decisions

- **Categories are user-created** — no predefined list
- **Limits are optional** — per subcategory
- **Photos stored locally** — in SwiftData as Data
- **Share Extension** — separate target, shared data via App Groups
- **Reminders sync** — deferred to Phase 3, no setup needed now

---

*Last updated: December 17, 2025*

