import ComposableArchitecture
import Foundation

@Reducer
struct SearchFeature {
  @ObservableState
  struct State: Equatable {
    var results: [GeocodingSearch.Result] = []
    var resultForecastRequestInFlight: GeocodingSearch.Result?
    var searchQuery = ""
    var weather: Weather?
    var mode: SearchMode = .mock

    struct Weather: Equatable {
      var id: GeocodingSearch.Result.ID
      var days: [Day]

      struct Day: Equatable {
        var date: Date
        var temperatureMax: Double
        var temperatureMaxUnit: String
        var temperatureMin: Double
        var temperatureMinUnit: String
      }
    }
  }

  enum SearchMode: String, CaseIterable, Equatable {
    case mock
    case live

    var title: String { rawValue.capitalized }
  }

  enum Action {
    case forecastResponse(GeocodingSearch.Result.ID, Result<Forecast, any Error>)
    case modeChanged(SearchMode)
    case searchQueryChanged(String)
    case searchQueryDebounced
    case searchResponse(Result<GeocodingSearch, any Error>)
    case searchResultTapped(GeocodingSearch.Result)
  }

  private enum CancelID {
    case location
    case weather
  }

  private let mockService: any WeatherServicing
  private let liveService: any WeatherServicing

  init(mockService: any WeatherServicing, liveService: any WeatherServicing) {
    self.mockService = mockService
    self.liveService = liveService
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .forecastResponse(_, .failure):
        state.weather = nil
        state.resultForecastRequestInFlight = nil
        return .none

      case let .forecastResponse(id, .success(forecast)):
        state.weather = State.Weather(
          id: id,
          days: forecast.daily.time.indices.map {
            State.Weather.Day(
              date: forecast.daily.time[$0],
              temperatureMax: forecast.daily.temperatureMax[$0],
              temperatureMaxUnit: forecast.dailyUnits.temperatureMax,
              temperatureMin: forecast.daily.temperatureMin[$0],
              temperatureMinUnit: forecast.dailyUnits.temperatureMin
            )
          }
        )
        state.resultForecastRequestInFlight = nil
        return .none

      case let .modeChanged(mode):
        state.mode = mode
        state.results = []
        state.weather = nil
        state.resultForecastRequestInFlight = nil
        return .merge(
          .cancel(id: CancelID.location),
          .cancel(id: CancelID.weather)
        )

      case let .searchQueryChanged(query):
        state.searchQuery = query

        guard !state.searchQuery.isEmpty else {
          state.results = []
          state.weather = nil
          state.resultForecastRequestInFlight = nil
          return .merge(
            .cancel(id: CancelID.location),
            .cancel(id: CancelID.weather)
          )
        }
        return .none

      case .searchQueryDebounced:
        guard !state.searchQuery.isEmpty else {
          return .none
        }

        let service = service(for: state.mode)
        return .run { [query = state.searchQuery] send in
          await send(.searchResponse(Result { try await service.search(query: query) }))
        }
        .cancellable(id: CancelID.location)

      case .searchResponse(.failure):
        state.results = []
        return .none

      case let .searchResponse(.success(response)):
        state.results = response.results
        return .none

      case let .searchResultTapped(location):
        state.resultForecastRequestInFlight = location

        let service = service(for: state.mode)
        return .run { send in
          await send(
            .forecastResponse(
              location.id,
              Result { try await service.forecast(location: location) }
            )
          )
        }
        .cancellable(id: CancelID.weather, cancelInFlight: true)
      }
    }
  }

  private func service(for mode: SearchMode) -> any WeatherServicing {
    switch mode {
    case .mock:
      mockService
    case .live:
      liveService
    }
  }
}
