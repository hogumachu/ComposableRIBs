import ComposableRIBs

@MainActor
protocol SearchRouting: RoutableViewControlling {}

@MainActor
protocol SearchBuildable {
  func build(with dependency: any SearchDependency) -> any SearchRouting
}

@MainActor
struct SearchBuilder: SearchBuildable {
  func build(with dependency: any SearchDependency) -> any SearchRouting {
    let interactor: TCAInteractor<SearchFeature> = TCAInteractor(initialState: SearchFeature.State()) {
      SearchFeature(
        mockService: dependency.mockWeatherService,
        liveService: dependency.liveWeatherService
      )
    }

    return SearchRouter(interactor: interactor)
  }
}
