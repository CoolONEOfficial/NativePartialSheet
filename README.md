# NativePartialSheet

Main feature of this library - native support of ***custom*** SwiftUI's presentationDetents from ***iOS 15.0*** 🔥

## Simple example

```swift
extension Detent {
    static let customCompact: Detent = .custom(constant: 100)
}

struct MyView: View {
    @State var isPresented = false

    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                NativePartialSheet() {
                    Text("Hello world")
                        .interactiveDismissDisabled()
                }
            }
    }
}
```

## Advanced example

```
import NativePartialSheet
import SwiftUI

extension Detent { // complile time static detents
    static let customCompact: Detent = .custom(constant: 100)
}

struct MyView: View {
    @State var isPresented = false
    @State var selectedDetent: Detent? = .customCompact
    @State var detents: [Detent] = [.large, .customCompact]

    var body: some View {
        Text("Open sheet")
            .onTapGesture {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                NativePartialSheet( // all params not required
                    detents: detents,
                    preferredCornerRadius: 32,
                    prefersGrabberVisible: false,
                    prefersEdgeAttachedInCompactHeight: false,
                    prefersScrollingExpandsWhenScrolledToEdge: true,
                    widthFollowsPreferredContentSizeWhenEdgeAttached: false,
                    largestUndimmedDetent: .medium,
                    selectedDetent: $selectedDetent
                ) {
                    Text("Hello world")
                        .interactiveDismissDisabled()
                }
                .onAppear {
                    // runtime calculated detent
                    let newDetent: Detent = .custom(constant: .init(400))
                    detents.append(newDetent)
                    selectedDetent = newDetent // animated by default
                }
            }
    }
}
```

## Screenshots
<p float="left">
  <img src="https://user-images.githubusercontent.com/18753760/190933073-5185fca7-1962-447c-9424-0da7f8ede7d3.png" width="250" />
  <img src="https://user-images.githubusercontent.com/18753760/190933093-180f954d-c6b3-49cd-88b6-9c9c5f630cb0.png" width="250" /> 
  <img src="https://user-images.githubusercontent.com/18753760/190933098-07d6abc7-c868-478e-96f9-30d3a7ecbb1f.png" width="250" />
</p>
