//
//  HorizontalItemPicker.swift
//  HorizontalItemPicker
//
//  Created by Anton Kaliuzhnyi on 16.10.2024.
//

import SwiftUI
import Combine

struct HorizontalItemPicker<Item: Identifiable, Content: View>: View {
    @Binding var items: [Item]
    @Binding var selectedItem: Item
    @State private var scrollViewSize: CGSize = .zero
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedItemId: Int = 0
    @State private var isScrolling = false
    private var itemsPerPage: CGFloat
    private var itemsWidthProportion: CGFloat { 1 / itemsPerPage }
    private var leadingItemsQuantity: CGFloat { (itemsPerPage - 1) / 2 }
    private let coordinateSpace: String = "HorizontalItemPicker"
    private let content: (Item) -> Content
    
    // The performance of this solution is not ideal in the eventTracking mode of macOS.
    // Source: https://fatbobman.com/en/posts/how_to_judge_scrollview_is_scrolling/
    private let idlePublisher = Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()
    private let scrollingPublisher = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
    
    private var publisher: some Publisher {
        scrollingPublisher
            .map { _ in 1 }
            .merge(with: idlePublisher.map { _ in 0 })
    }
    
    @State private var cancellable: AnyCancellable?
    
    init(items: Binding<[Item]>, selectedItem: Binding<Item>, itemsPerPage: CGFloat = 4, @ViewBuilder content: @escaping (Item) -> Content) {
        self._items = items
        self._selectedItem = selectedItem
        self.content = content
        self.itemsPerPage = itemsPerPage
    }
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(items) { item in
                        HorizontalItemView(parentWidth: scrollViewSize.width, coordinateSpace: coordinateSpace, action: {
                            withAnimation {
                                let anchor = if #available(iOS 17, *) {
                                    UnitPoint.center
                                } else {
                                    UnitPoint(x: 1, y: 0.5)
                                }
                                scrollView.scrollTo(item.id, anchor: anchor)
                                selectedItem = item
                            }
                        }, content: {
                            content(item)
                        })
                        .frame(width: scrollViewSize.width * itemsWidthProportion)
                    }
                }
                .padding(.horizontal, scrollViewSize.width * itemsWidthProportion * leadingItemsQuantity)
                .background(GeometryReader { g in
                    Color.clear
                        .preference(key: HorizontalItemPickerOffsetKey.self, value: g.frame(in: .named(coordinateSpace)).origin.x)
                })
                .onPreferenceChange(HorizontalItemPickerOffsetKey.self) { value in
                    scrollOffset = value
                }
            }
            .coordinateSpace(name: coordinateSpace)
            .background(GeometryReader { g in
                Color.clear
                    .preference(key: HorizontalItemPickerSizePreferenceKey.self, value: g.size)
            })
            .onPreferenceChange(HorizontalItemPickerSizePreferenceKey.self) { value in
                scrollViewSize = value
            }
            .onChange(of: isScrolling) { newValue in
                guard !newValue else { return }
                let scrollCenter = (scrollViewSize.width / 2) - scrollOffset
                for (i, item) in items.enumerated() {
                    let cardWidth = scrollViewSize.width * itemsWidthProportion
                    let leadingPadding = cardWidth * leadingItemsQuantity
                    let minX = leadingPadding + (cardWidth * CGFloat(i))
                    let maxX = minX + cardWidth
                    if (minX...maxX).contains(scrollCenter) {
                        withAnimation {
                            let anchor = if #available(iOS 17, *) {
                                UnitPoint.center
                            } else {
                                UnitPoint(x: 1, y: 0.5)
                            }
                            scrollView.scrollTo(item.id, anchor: anchor)
                            selectedItem = item
                        }
                        return
                    }
                }
            }
        }
        .onAppear {
            guard cancellable == nil else { return }
            cancellable = publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in }, receiveValue: { output in
                    guard let value = output as? Int else { return }
                    if value == 1,!isScrolling {
                        isScrolling = true
                    }
                    if value == 0, isScrolling {
                        isScrolling = false
                    }
                })
        }
    }
}

private struct HorizontalItemPickerOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

private struct HorizontalItemPickerSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let maxWidth = max(value.width, nextValue().width)
        let maxHeight = max(value.height, nextValue().height)
        value = CGSize(width: maxWidth, height: maxHeight)
    }
}

// Example usage

private struct HorizontalItemPickerPreview: View {
    struct Item: Identifiable {
        let id: Int
    }
    @State private var items: [Item] = [.init(id: 0), .init(id: 1), .init(id: 2), .init(id: 3), .init(id: 4), .init(id: 5)]
    @State private var selectedItem: Item = .init(id: 0)
    var body: some View {
        HorizontalItemPicker(items: $items, selectedItem: $selectedItem, itemsPerPage: 4) { item in
            Text("Card\n\(item.id)")
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
        }
        .background(Color.accentColor.opacity(0.05))
    }
}

#Preview {
    HorizontalItemPickerPreview()
}
