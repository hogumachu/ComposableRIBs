import ComposableArchitecture
import SwiftUI

struct ChildView: View {
  @ObservedObject var router: ChildRouter

  var body: some View {
    WithViewStore(router.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 12) {
        Text("Child")
          .font(.headline)

        Text("Lifecycle: \(viewStore.isActive ? "Active" : "Inactive")")
          .foregroundStyle(viewStore.isActive ? .green : .secondary)
        Text("Seed: \(viewStore.seedValue), ticks: \(viewStore.ticks)")

        Button(viewStore.showGrandchild ? "Detach Grandchild" : "Attach Grandchild") {
          router.toggleGrandchildAttachment()
        }
        .buttonStyle(.bordered)

        if router.isGrandchildAttached {
          GrandchildView(router: router.grandchildRouter)
        }
      }
      .padding()
      .background(Color.blue.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}
