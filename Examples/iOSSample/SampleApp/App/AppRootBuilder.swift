import SwiftUI
import UIKit

@MainActor
struct AppRootBuilder {
  func build() -> UIViewController {
    let router = ParentBuilder().build(with: SampleAppDependency(initialCounter: 1))
    router.interactor.activate()
    return UIHostingController(rootView: ParentView(router: router))
  }
}
