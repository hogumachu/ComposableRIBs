import ComposableArchitecture
import ComposableRIBs
import Combine

@MainActor
final class ParentRouter: BaseRouter, ObservableObject {
  let store: StoreOf<ParentFeature>
  let interactor: TCAInteractor<ParentFeature>
  let childRouter: ChildRouter

  @Published private(set) var isChildAttached = false

  init(store: StoreOf<ParentFeature>, interactor: TCAInteractor<ParentFeature>, childRouter: ChildRouter) {
    self.store = store
    self.interactor = interactor
    self.childRouter = childRouter
    super.init()
  }

  func toggleChildAttachment() {
    if isChildAttached {
      childRouter.interactor.deactivate()
      childRouter.grandchildRouter.interactor.deactivate()
      if childRouter.isGrandchildAttached {
        childRouter.toggleGrandchildAttachment()
      }
      detachChild(childRouter)
    } else {
      attachChild(childRouter)
      childRouter.interactor.activate()
    }
    isChildAttached.toggle()
    _ = store.send(.toggleChildTapped)
  }
}
