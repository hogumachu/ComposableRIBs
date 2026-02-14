import Foundation

protocol WeatherServicing: Sendable {
  func search(query: String) async throws -> GeocodingSearch
  func forecast(location: GeocodingSearch.Result) async throws -> Forecast
}

struct MockWeatherService: WeatherServicing {
  func search(query: String) async throws -> GeocodingSearch {
    guard !query.isEmpty else { return GeocodingSearch(results: []) }
    let results = GeocodingSearch.mock.results.filter { result in
      result.name.localizedCaseInsensitiveContains(query)
    }
    return GeocodingSearch(results: results)
  }

  func forecast(location: GeocodingSearch.Result) async throws -> Forecast {
    Forecast.mock
  }
}

struct LiveWeatherService: WeatherServicing {
  private let session: URLSession

  init(session: URLSession = .shared) {
    self.session = session
  }

  func search(query: String) async throws -> GeocodingSearch {
    var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
    components.queryItems = [URLQueryItem(name: "name", value: query)]

    let (data, _) = try await session.data(from: components.url!)
    return try jsonDecoder.decode(GeocodingSearch.self, from: data)
  }

  func forecast(location: GeocodingSearch.Result) async throws -> Forecast {
    var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
    components.queryItems = [
      URLQueryItem(name: "latitude", value: "\(location.latitude)"),
      URLQueryItem(name: "longitude", value: "\(location.longitude)"),
      URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min"),
      URLQueryItem(name: "timezone", value: TimeZone.autoupdatingCurrent.identifier),
    ]

    let (data, _) = try await session.data(from: components.url!)
    return try jsonDecoder.decode(Forecast.self, from: data)
  }
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  formatter.calendar = Calendar(identifier: .iso8601)
  formatter.dateFormat = "yyyy-MM-dd"
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.locale = Locale(identifier: "en_US_POSIX")
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()

extension Forecast {
  static let mock = Self(
    daily: Daily(
      temperatureMax: [90, 70, 100],
      temperatureMin: [70, 50, 80],
      time: [0, 86_400, 172_800].map(Date.init(timeIntervalSince1970:))
    ),
    dailyUnits: DailyUnits(temperatureMax: "°F", temperatureMin: "°F")
  )
}

extension GeocodingSearch {
  static let mock = Self(
    results: [
      GeocodingSearch.Result(
        country: "United States",
        latitude: 40.6782,
        longitude: -73.9442,
        id: 1,
        name: "Brooklyn",
        admin1: nil
      ),
      GeocodingSearch.Result(
        country: "United States",
        latitude: 34.0522,
        longitude: -118.2437,
        id: 2,
        name: "Los Angeles",
        admin1: nil
      ),
      GeocodingSearch.Result(
        country: "United States",
        latitude: 37.7749,
        longitude: -122.4194,
        id: 3,
        name: "San Francisco",
        admin1: nil
      ),
    ]
  )
}
