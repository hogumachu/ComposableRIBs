import ComposableArchitecture
import SwiftUI

struct ParentView: View {
  let store: StoreOf<ParentFeature>

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        Text("Parent")
          .font(.title2.bold())
        Text("Lifecycle: \(store.isActive ? "Active" : "Inactive")")
          .foregroundStyle(store.isActive ? .green : .secondary)
        Text("Counter: \(store.counter)")

        Text("Child Presented: \(store.isChildPresented ? "Yes" : "No")")

        Button("Show Child") {
          store.send(.childButtonTapped)
        }
        .buttonStyle(.borderedProminent)
      }
      .padding()
    }
    .navigationTitle("Parent")
    .background(Color(.systemGroupedBackground))
  }
}
