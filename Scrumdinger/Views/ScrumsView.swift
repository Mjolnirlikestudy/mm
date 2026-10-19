import SwiftUI

struct ScrumsView: View {
    @StateObject private var store = ScrumStore()
    @State private var isPresentingNewScrumView = false
    @State private var detailScrumID: UUID?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if store.scrums.isEmpty {
                        EmptyStateView(icon: "person.3",
                                       title: "No Daily Scrums",
                                       message: "Tap + to add your first daily scrum.")
                    } else {
                        ForEach($store.scrums) { $scrum in
                            NavigationLink {
                                MeetingView(scrum: $scrum)
                            } label: {
                                CardView(scrum: scrum)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    detailScrumID = scrum.id
                                } label: {
                                    Label("Details", systemImage: "info.circle")
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Daily Scrums")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingNewScrumView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("New Scrum")
                }
            }
            .sheet(isPresented: $isPresentingNewScrumView) {
                NewScrumSheet(scrums: $store.scrums)
            }
            .sheet(item: $store.error) { errorWrapper in
                ErrorView(errorWrapper: errorWrapper)
            }
            .navigationDestination(isPresented: isShowingDetail) {
                detailDestination
            }
        }
    }

    private var isShowingDetail: Binding<Bool> {
        Binding {
            detailScrumID != nil
        } set: { isPresented in
            if !isPresented {
                detailScrumID = nil
            }
        }
    }

    @ViewBuilder
    private var detailDestination: some View {
        if let id = detailScrumID,
           let index = store.scrums.firstIndex(where: { $0.id == id }) {
            DetailView(scrum: $store.scrums[index])
        } else {
            EmptyStateView(icon: "questionmark.circle",
                           title: "Scrum not found",
                           message: "")
        }
    }
}

#Preview {
    RootTabView()
}
