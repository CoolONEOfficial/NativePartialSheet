# NativePartialSheet

Main feature of this library - native support of ***custom*** SwiftUI's presentationDetents from ***iOS 15.0*** 🔥

## Screenshots
<p float="left">
  <img src="https://user-images.githubusercontent.com/18753760/190933073-5185fca7-1962-447c-9424-0da7f8ede7d3.png" width="250" />
  <img src="https://user-images.githubusercontent.com/18753760/190933093-180f954d-c6b3-49cd-88b6-9c9c5f630cb0.png" width="250" /> 
  <img src="https://user-images.githubusercontent.com/18753760/190933098-07d6abc7-c868-478e-96f9-30d3a7ecbb1f.png" width="250" />
</p>

## Simple examples

### Classic isPresented way

```swift
import SwiftUI
import NativePartialSheet

struct ContentView: View {
    @State var isPresented = false

    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                Text("Sheet content")
            }
            .presentationDetents([ .large, .medium ])
    }
}
```

### Optional detent way

```swift
import SwiftUI
import NativePartialSheet

struct ContentView: View {
    @State var detent: Detent?
    
    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                detent = .medium
            }
            .sheet(selectedDetent: $detent) { detent in
                switch detent {
                case .medium:
                    Text("Medium")
                case .large:
                    Text("Large")
                default:
                    EmptyView()
                }
            }
            .presentationDetents([ .large, .medium ])
    }
}
```

## Advanced examples

### Sheet configuration

```swift
import SwiftUI
import NativePartialSheet

struct ContentView: View {
    @State var isPresented = false
    @State var detent: Detent = .medium

    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                Text("Sheet content")
            }
            .presentationDetents([ .medium, .large ], selection: $detent)
            .cornerRadius(32)
            .presentationDragIndicator(.visible)
            .edgeAttachedInCompactHeight(true)
            .scrollingExpandsWhenScrolledToEdge(true)
            .widthFollowsPreferredContentSizeWhenEdgeAttached(true)
            .largestUndimmedDetent(.medium)
            .interactiveDismissDisabled(true, onWillDismiss: onWillDismiss, onDidDismiss: onDidDismiss)
    }
    
    func onDidDismiss() {
        debugPrint("DID")
    }
    
    func onWillDismiss() {
        debugPrint("WILL")
    }
}
```

### Use with item

```swift
import SwiftUI
import NativePartialSheet

struct MyItem: Identifiable {
    var content: String
    var id: String { content }
}

struct ContentView: View {
    @State var item: MyItem?

    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                item = .init(content: "Test content")
            }
            .sheet(item: $item) { item in
                VStack {
                    Button("recreate") {
                        self.item = .init(content: "Recreated content")
                    }
                    Button("change") {
                        self.item?.content = "Changed content"
                    }
                    Text(item.content)
                }
            }
            .presentationDetents([ .large, .medium ])
    }
}
```

### Custom static detents

```swift
import SwiftUI
import NativePartialSheet

extension Detent {
    static let customSmall: Detent = .height(100)
}

struct ContentView: View {
    @State var detent: Detent?
    
    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                detent = .customSmall
            }
            .sheet(selectedDetent: $detent) { detent in
                switch detent {
                case .medium:
                    Text("Medium")
                case .large:
                    Text("Large")
                case .customSmall:
                    Text("Custom small")
                default:
                    EmptyView()
                }
            }
            .presentationDetents([ .large, .medium, .customSmall ])
    }
}
```

### Custom dynamic detents

```swift
import SwiftUI
import NativePartialSheet

struct ContentView: View {
    @State var detent: Detent?
    @State var detents: Set<Detent> = [ .large, .medium ]
    
    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                let dynamic = Detent.height(123)
                detents.insert(dynamic)
                detent = dynamic
            }
            .sheet(selectedDetent: $detent) { detent in
                switch detent {
                case .height(_):
                    Text("Dynamic")
                case .medium:
                    Text("Medium")
                case .large:
                    Text("Large")
                }
            }
            .presentationDetents(detents)
    }
}
```
