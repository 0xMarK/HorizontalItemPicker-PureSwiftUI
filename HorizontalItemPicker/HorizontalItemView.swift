//
//  HorizontalItemView.swift
//  HorizontalItemPicker
//
//  Created by Anton Kaliuzhnyi on 16.10.2024.
//

import SwiftUI

struct HorizontalItemView<Content: View>: View {
    var parentWidth: CGFloat
    var coordinateSpace: String
    var action: () -> Void
    @ViewBuilder var content: () -> Content
    @State private var midX: CGFloat = 0
    var body: some View {
        HStack {
            let itemCenter = midX
            let parentCenter = parentWidth / 2
            let distance = abs(itemCenter - parentCenter)
            let scale = max(1 - distance / parentCenter, 0.75)
            Button(action: action, label: content)
                .scaleEffect(scale)
        }
        .background(GeometryReader { g in
            Color.clear
                .preference(key: HorizontalItemViewMidXKey.self, value: g.frame(in: .named(coordinateSpace)).midX)
        })
        .onPreferenceChange(HorizontalItemViewMidXKey.self) { value in
            midX = value
        }
    }
}

#Preview {
    HorizontalItemView(parentWidth: 300, coordinateSpace: "", action: {}, content: { Text("Item") })
}

private struct HorizontalItemViewMidXKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
