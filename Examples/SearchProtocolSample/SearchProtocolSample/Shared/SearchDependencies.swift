import ComposableRIBs

protocol SearchDependency: RIBDependency {
  var mockWeatherService: any WeatherServicing { get }
  var liveWeatherService: any WeatherServicing { get }
}

struct SearchAppDependency: SearchDependency {
  let mockWeatherService: any WeatherServicing
  let liveWeatherService: any WeatherServicing

  init(
    mockWeatherService: any WeatherServicing = MockWeatherService(),
    liveWeatherService: any WeatherServicing = LiveWeatherService()
  ) {
    self.mockWeatherService = mockWeatherService
    self.liveWeatherService = liveWeatherService
  }
}
