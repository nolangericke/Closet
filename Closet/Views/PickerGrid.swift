//
//  PickerGrid.swift
//  Closet
//
//  Created by Nolan Gericke on 12/18/25.
//


import SwiftUI

// MARK: - Generic Picker Grid

struct PickerGrid<Item: Hashable, Content: View>: View {
    let items: [Item]
    @Binding var selection: Item?
    @ViewBuilder let content: (Item, Bool) -> Content
    
    var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 50), spacing: 16)], spacing: 16) {
            ForEach(items, id: \.self) { item in
                Button {
                    selection = item
                } label: {
                    content(item, selection == item)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Icon Cell

struct IconCell: View {
    let name: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.blue.opacity(0.3) : Color(.secondarySystemFill))
            Image(systemName: name)
                .foregroundStyle(isSelected ? .blue : .primary)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Color Cell

struct ColorCell: View {
    let color: Color
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(color)

            if isSelected {
                Circle()
                    .stroke(.white, lineWidth: 3)

                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Icon Catalog

enum IconCatalog {
    static let clothing = [
        "tshirt.fill", "shoe.fill", "eyeglasses", "bag.fill", "handbag.fill", "comb"
    ]
    static let home = [
        "house.fill", "bed.double.fill", "sofa.fill", "lamp.desk.fill", "fan.fill"
    ]
    static let electronics = [
        "laptopcomputer", "desktopcomputer", "tv.fill", "headphones", "gamecontroller.fill"
    ]
    static let kitchen = [
        "fork.knife", "cup.and.saucer.fill", "refrigerator.fill", "oven.fill"
    ]
    static let office = [
        "briefcase.fill", "doc.fill", "book.fill", "pencil.and.ruler.fill"
    ]
    static let sports = [
        "figure.run", "bicycle", "tennisball.fill", "soccerball"
    ]
    static let storage = [
        "folder.fill", "archivebox.fill", "shippingbox.fill", "tray.full.fill"
    ]
    static let misc = [
        "star.fill", "heart.fill", "tag.fill", "gift.fill", "cart.fill"
    ]
    static let all: [String] = [
        clothing, home, electronics, kitchen, office, sports, storage, misc
    ].flatMap { $0 }
}

// MARK: - Color Catalog

enum ColorCatalog {
    static let all: [Color] = [
        .red, .orange, .yellow, .green, .mint, .blue, .purple, .pink, .gray, .brown
    ]
}

// MARK: - Previews

#Preview("Icon Picker") {
    struct IconPickerDemo: View {
        @State private var selectedIcon: String?
        var body: some View {
            ScrollView {
                PickerGrid(items: IconCatalog.all, selection: $selectedIcon) { icon, isSelected in
                    IconCell(name: icon, isSelected: isSelected)
                }
                .padding()
            }
        }
    }
    return IconPickerDemo()
}

#Preview("Color Picker") {
    struct ColorPickerDemo: View {
        @State private var selectedColor: Color?
        var body: some View {
            ScrollView {
                PickerGrid(items: ColorCatalog.all, selection: $selectedColor) { color, isSelected in
                    ColorCell(color: color, isSelected: isSelected)
                }
                .padding()
            }
        }
    }
    return ColorPickerDemo()
}
