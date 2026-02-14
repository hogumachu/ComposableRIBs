import ComposableArchitecture
import SwiftUI

private let readMe = """
  This sample ports TCA Search UX into ComposableRIBs using protocol-first dependency injection.
  It avoids @Dependency and injects mock/live weather services through RIB contracts.
  """

struct SearchView: View {
  @Bindable var store: StoreOf<SearchFeature>

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        Text(readMe)
          .padding()

        Picker("Mode", selection: $store.mode.sending(\.modeChanged)) {
          ForEach(SearchFeature.SearchMode.allCases, id: \.self) { mode in
            Text(mode.title).tag(mode)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)

        HStack {
          Image(systemName: "magnifyingglass")
          TextField(
            "New York, San Francisco, ...", text: $store.searchQuery.sending(\.searchQueryChanged)
          )
          .textFieldStyle(.roundedBorder)
          .autocapitalization(.none)
          .disableAutocorrection(true)
        }
        .padding(.horizontal, 16)

        List {
          ForEach(store.results) { location in
            VStack(alignment: .leading) {
              Button {
                store.send(.searchResultTapped(location))
              } label: {
                HStack {
                  Text(location.name)
                  if let admin1 = location.admin1 {
                    Text("(\(admin1))")
                  }

                  if store.resultForecastRequestInFlight?.id == location.id {
                    ProgressView()
                  }
                }
              }

              if location.id == store.weather?.id {
                weatherView(locationWeather: store.weather)
              }
            }
          }
        }

        Link("Weather API provided by Open-Meteo", destination: URL(string: "https://open-meteo.com/en")!)
          .foregroundColor(.gray)
          .padding(.all, 16)
      }
      .navigationTitle("Search")
    }
    .task(id: store.searchQuery) {
      do {
        try await Task.sleep(for: .milliseconds(300))
        await store.send(.searchQueryDebounced).finish()
      } catch {
        // Debounce cancellation is expected while the user types.
      }
    }
  }

  @ViewBuilder
  private func weatherView(locationWeather: SearchFeature.State.Weather?) -> some View {
    if let locationWeather {
      let days = locationWeather.days
        .enumerated()
        .map { idx, weather in formattedWeather(day: weather, isToday: idx == 0) }

      VStack(alignment: .leading) {
        ForEach(days, id: \.self) { day in
          Text(day)
        }
      }
      .padding(.leading, 16)
    }
  }
}

private func formattedWeather(day: SearchFeature.State.Weather.Day, isToday: Bool) -> String {
  let date = isToday ? "Today" : dateFormatter.string(from: day.date).capitalized
  let min = "\(day.temperatureMin)\(day.temperatureMinUnit)"
  let max = "\(day.temperatureMax)\(day.temperatureMaxUnit)"

  return "\(date), \(min) – \(max)"
}

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "EEEE"
  return formatter
}()

#Preview {
  SearchView(
    store: Store(initialState: SearchFeature.State()) {
      SearchFeature(mockService: MockWeatherService(), liveService: MockWeatherService())
    }
  )
}
