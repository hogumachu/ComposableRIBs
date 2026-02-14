import Foundation

struct GeocodingSearch: Decodable, Equatable, Sendable {
  var results: [Result]

  struct Result: Decodable, Equatable, Identifiable, Sendable {
    var country: String
    var latitude: Double
    var longitude: Double
    var id: Int
    var name: String
    var admin1: String?
  }
}

struct Forecast: Decodable, Equatable, Sendable {
  var daily: Daily
  var dailyUnits: DailyUnits

  struct Daily: Decodable, Equatable, Sendable {
    var temperatureMax: [Double]
    var temperatureMin: [Double]
    var time: [Date]
  }

  struct DailyUnits: Decodable, Equatable, Sendable {
    var temperatureMax: String
    var temperatureMin: String
  }
}

extension Forecast {
  enum CodingKeys: String, CodingKey {
    case daily
    case dailyUnits = "daily_units"
  }
}

extension Forecast.Daily {
  enum CodingKeys: String, CodingKey {
    case temperatureMax = "temperature_2m_max"
    case temperatureMin = "temperature_2m_min"
    case time
  }
}

extension Forecast.DailyUnits {
  enum CodingKeys: String, CodingKey {
    case temperatureMax = "temperature_2m_max"
    case temperatureMin = "temperature_2m_min"
  }
}
