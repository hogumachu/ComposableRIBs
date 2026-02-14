import ComposableArchitecture
import SwiftUI

struct ParentView: View {
  @ObservedObject var router: ParentRouter

  var body: some View {
    WithViewStore(router.store, observe: { $0 }) { viewStore in
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          Text("Parent")
            .font(.title2.bold())
          Text("Lifecycle: \(viewStore.isActive ? "Active" : "Inactive")")
            .foregroundStyle(viewStore.isActive ? .green : .secondary)
          Text("Counter: \(viewStore.counter)")

          Button(viewStore.showChild ? "Detach Child" : "Attach Child") {
            router.toggleChildAttachment()
          }
          .buttonStyle(.borderedProminent)

          if router.isChildAttached {
            ChildView(router: router.childRouter)
          }
        }
        .padding()
      }
      .background(Color(.systemGroupedBackground))
    }
  }
}
