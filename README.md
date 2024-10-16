# HorizontalItemPicker-PureSwiftUI

A convenient horizontal item picker written purely in SwiftUI.

Usage example:

```swift
HorizontalItemPicker(items: $items, selectedItem: $selectedItem, itemsPerPage: 4, content: { item in
    Text("\(item.id)")
})
```
