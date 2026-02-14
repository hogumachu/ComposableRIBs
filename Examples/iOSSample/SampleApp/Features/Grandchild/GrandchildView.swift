import ComposableArchitecture
import SwiftUI

struct GrandchildView: View {
  let router: GrandchildRouter

  var body: some View {
    WithViewStore(router.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 8) {
        Text("Grandchild")
          .font(.headline)
        Text(viewStore.title)
        Text("Lifecycle: \(viewStore.isActive ? "Active" : "Inactive")")
          .foregroundStyle(viewStore.isActive ? .green : .secondary)
      }
      .padding()
      .background(Color.orange.opacity(0.15))
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}
