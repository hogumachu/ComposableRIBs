import ComposableArchitecture
import SwiftUI

struct GrandchildView: View {
  let store: StoreOf<GrandchildFeature>

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Grandchild")
        .font(.headline)
      Text(store.title)
      Text("Lifecycle: \(store.isActive ? "Active" : "Inactive")")
        .foregroundStyle(store.isActive ? .green : .secondary)

      Button("Close Grandchild") {
        store.send(.closeTapped)
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .navigationTitle("Grandchild")
    .navigationBarBackButtonHidden(true)
    .background(Color.orange.opacity(0.15))
  }
}
