import ComposableArchitecture
import ComposableRIBs

@MainActor
final class GrandchildRouter: BaseRouter {
  let store: StoreOf<GrandchildFeature>
  let interactor: TCAInteractor<GrandchildFeature>

  init(store: StoreOf<GrandchildFeature>, interactor: TCAInteractor<GrandchildFeature>) {
    self.store = store
    self.interactor = interactor
    super.init()
  }
}
