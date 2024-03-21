import SwiftUI

struct MyTabItem<Content: View>: View {
    var content: Content
    var text:String
    
    var image:String
    var body: some View {
        NavigationView{
            content
        }
                .tabItem {
                    Image(systemName: image)
                    Text(text)
                }

    }
}
