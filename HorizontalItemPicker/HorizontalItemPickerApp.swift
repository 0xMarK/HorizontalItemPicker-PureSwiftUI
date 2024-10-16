//
//  HorizontalItemPickerApp.swift
//  HorizontalItemPicker
//
//  Created by Anton Kaliuzhnyi on 16.10.2024.
//

import SwiftUI

struct CardItem: Identifiable {
    let id: Int
}

@main
struct HorizontalItemPickerApp: App {
    @State private var items = [CardItem(id: 0), CardItem(id: 1), CardItem(id: 2), CardItem(id: 3), CardItem(id: 4), CardItem(id: 5), CardItem(id: 6), CardItem(id: 7), CardItem(id: 8)]
    @State private var selectedItem: CardItem = CardItem(id: 0)
    var body: some Scene {
        WindowGroup {
            Text("Selected item id: \(String(describing: selectedItem.id))")
            HStack {
                Text("Left")
                HorizontalItemPicker(items: $items, selectedItem: $selectedItem, itemsPerPage: 4, content: { item in
                    Text("Сard\n\(item.id)")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
                })
            }
            Text("Bottom")
        }
    }
}
