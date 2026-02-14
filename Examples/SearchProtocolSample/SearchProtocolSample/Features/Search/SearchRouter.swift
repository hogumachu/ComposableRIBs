import ComposableRIBs

@MainActor
final class SearchRouter: SwiftUIHostingRouter<SearchFeature, SearchView>, SearchRouting {
  init(interactor: TCAInteractor<SearchFeature>) {
    super.init(interactor: interactor) {
      SearchView(store: $0)
    }
  }
}
