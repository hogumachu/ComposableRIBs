import ComposableArchitecture
import SwiftUI

struct ChildView: View {
  let store: StoreOf<ChildFeature>

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Child")
        .font(.headline)

      Text("Lifecycle: \(store.isActive ? "Active" : "Inactive")")
        .foregroundStyle(store.isActive ? .green : .secondary)
      Text("Seed: \(store.seedValue), ticks: \(store.ticks)")

      Button(store.showGrandchild ? "Close Grandchild" : "Show Grandchild") {
        store.send(.grandchildButtonTapped)
      }
      .buttonStyle(.bordered)

      Button("Close Child") {
        store.send(.closeTapped)
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .navigationTitle("Child")
    .navigationBarBackButtonHidden(true)
    .background(Color.blue.opacity(0.1))
  }
}
