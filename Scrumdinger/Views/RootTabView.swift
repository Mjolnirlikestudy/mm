import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ScrumsView()
                .tabItem {
                    Label("Daily Scrums", systemImage: "person.3.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.circle")
                }
        }
        .tint(.accentColor)
    }
}

#Preview {
    RootTabView()
}
