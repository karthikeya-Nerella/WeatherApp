import SwiftUI

struct WeatherSearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @StateObject private var imageLoader = ImageLoader(cache: AppContainer().imageCache)

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TextField(LocalizedStringKey("enter_us_city"), text: $viewModel.query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .accessibilityLabel(LocalizedStringKey("enter_city_accessibility"))
                    .accessibilityIdentifier("cityTextField")
                Button(LocalizedStringKey("search")) {
                    Task { await viewModel.search() }
                }
                .accessibilityLabel(LocalizedStringKey("search_button_accessibility"))
                .accessibilityIdentifier("searchButton")
            }
            if viewModel.isLoading { ProgressView() }
            if let m = viewModel.uiModel {
                VStack(spacing: 8) {
                    Text(m.city).font(.title).bold()
                    Text(m.temperature).font(.largeTitle)
                    Text(m.description.capitalized).font(.body)
                    if let url = m.iconURL {
                        IconImage(url: url, imageLoader: imageLoader)
                            .frame(width: 100, height: 100)
                            .accessibilityLabel(LocalizedStringKey("weather_icon_accessibility"))
                            .accessibilityIdentifier("weatherIcon")
                    }
                }
            }
            if let e = viewModel.errorMessage { Text(e).foregroundColor(.red) }
            Spacer()
        }
        .padding()
        .onAppear { viewModel.onAppear() }
        .navigationBarTitleDisplayMode(.automatic)
    }
}

struct IconImage: View {
    let url: URL
    @ObservedObject var imageLoader: ImageLoader

    var body: some View {
        ZStack {
            if let image = imageLoader.image {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                ProgressView().onAppear { imageLoader.load(url: url) }
            }
        }
    }
}