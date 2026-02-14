import ComposableArchitecture
import ComposableRIBs
import Combine

@MainActor
final class ChildRouter: BaseRouter, ObservableObject {
  let store: StoreOf<ChildFeature>
  let interactor: TCAInteractor<ChildFeature>
  let grandchildRouter: GrandchildRouter

  @Published private(set) var isGrandchildAttached = false

  init(
    store: StoreOf<ChildFeature>,
    interactor: TCAInteractor<ChildFeature>,
    grandchildRouter: GrandchildRouter
  ) {
    self.store = store
    self.interactor = interactor
    self.grandchildRouter = grandchildRouter
    super.init()
  }

  func toggleGrandchildAttachment() {
    if isGrandchildAttached {
      detachChild(grandchildRouter)
      grandchildRouter.interactor.deactivate()
    } else {
      attachChild(grandchildRouter)
      grandchildRouter.interactor.activate()
    }
    isGrandchildAttached.toggle()
    _ = store.send(.toggleGrandchildTapped)
  }
}
