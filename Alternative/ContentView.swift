import SwiftUI


struct ContentView: View {

    @State private var selection = 1
    @ObservedObject var firebaseManager = FirebaseManager.shared

    
    var body: some View {
        if firebaseManager.isAuth {
            TabView (selection: $selection) {
                MyTabItem(content: EmptyView(), text:"Для симметрии",
                          image:"circle.fill"
                )
                .tag(0)
                MyTabItem(content: HomeView(firebaseManager: firebaseManager), text:"Главная",
                          image:"house.fill"
                )
                .tag(1)
                MyTabItem(content: ProfileView(firebaseManager: firebaseManager), text:"Профиль",
                          image:"face.smiling.inverse"
                )
                .tag(2)
            }
        }
        else {
            LoginView(firebaseManager: firebaseManager)
        }
    }
}

#Preview {
    ContentView()
}
