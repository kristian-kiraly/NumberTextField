# NumberTextField

A SwiftUI-style TextField that allows a passed Binding number (Double, Int, or Float) to be internally managed and only allow valid numbers to be typed and pasted.

Usage:

```swift
struct MainContentView: View {
    @State var numCookies:Int = 1
    
    var body:some View {
        HStack {
            Text("How many cookies would you like?")
            Spacer()
            NumberTextField(number: $numCookies)
        }
    }
}
```

There are parameters that allow you to set placeholder text and a flag if you'd like the field to start blank if the initial value is 0

Please note: the clear button will not function if you are capturing gestures on views that contain the text field

I highly recommend against using Floats, the behavior gets quite strange when Float precision starts rearing its ugly head. But it is available if it must be used
