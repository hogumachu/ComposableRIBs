import ComposableArchitecture
import SwiftUI

struct ChildView: View {
  let store: StoreOf<ChildFeature>

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Child")
        .font(.headline)

      Text("Seed: \(store.seedValue), ticks: \(store.ticks)")

      Button("Show Grandchild") {
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
    .onAppear {
      store.send(.viewAppeared)
    }
    .onDisappear {
      store.send(.viewDisappeared)
    }
  }
}
