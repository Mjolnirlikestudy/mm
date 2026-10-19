import SwiftUI

struct NewScrumSheet: View {
    @Binding var scrums: [DailyScrum]

    var body: some View {
        NavigationStack {
            DetailEditView(scrum: DailyScrum(title: "",
                                             attendees: [],
                                             lengthInMinutes: 5,
                                             theme: .indigo)) { newScrum in
                scrums.append(newScrum)
            }
        }
    }
}

#Preview {
    NewScrumSheet(scrums: .constant(DailyScrum.sampleData))
}
