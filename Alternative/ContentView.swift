import SwiftUI


struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    @State private var selection = 1
    var body: some View {
        if isAuthenticated {
            TabView (selection: $selection) {
                MyTabItem(content: EmptyView(), text:"Для симметричности",
                          image:"circle.fill"
                )
                .tag(0)
                MyTabItem(content: HomeView(), text:"Главная",
                          image:"circle.fill"
                )
                .tag(1)
                MyTabItem(content: EmptyView(), text:"Профиль",
                          image:"circle.fill"
                )
                .tag(2)
            }
            
        }
        else {
            LoginView(isAuthenticated: $isAuthenticated)
        }
    }
}

#Preview {
    ContentView()
}
