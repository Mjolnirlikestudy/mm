import SwiftUI

struct ScrumsView: View {
    @StateObject private var store = ScrumStore()
    @State private var isPresentingNewScrumView = false

    var body: some View {
        NavigationStack {
            List($store.scrums) { $scrum in
                NavigationLink {
                    DetailView(scrum: $scrum)
                } label: {
                    CardView(scrum: scrum)
                }
                .listRowBackground(scrum.theme.main)
            }
            .overlay {
                if store.scrums.isEmpty {
                    ContentUnavailableView("No Daily Scrums",
                                           systemImage: "person.3",
                                           description: Text("Tap + to add your first daily scrum."))
                }
            }
            .navigationTitle("Daily Scrums")
            .toolbar {
                Button {
                    isPresentingNewScrumView = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Scrum")
            }
            .sheet(isPresented: $isPresentingNewScrumView) {
                NewScrumSheet(scrums: $store.scrums)
            }
            .sheet(item: $store.error) { errorWrapper in
                ErrorView(errorWrapper: errorWrapper)
            }
        }
    }
}

#Preview {
    ScrumsView()
}
