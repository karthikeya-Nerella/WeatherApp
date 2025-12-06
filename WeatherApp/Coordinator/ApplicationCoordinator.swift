import UIKit
import SwiftUI

final class ApplicationCoordinator {
    private let navigationController: UINavigationController
    private let container: AppContainer

    init(navigationController: UINavigationController, container: AppContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let vm = WeatherViewModel(services: container)
        let view = WeatherSearchView(viewModel: vm)
        let hosting = UIHostingController(rootView: view)
        hosting.title = "Weather"
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([hosting], animated: false)
    }
}