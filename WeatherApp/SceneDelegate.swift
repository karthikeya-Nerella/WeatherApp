import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coordinator: ApplicationCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let nav = UINavigationController()
        let container = AppContainer()
        let coordinator = ApplicationCoordinator(navigationController: nav, container: container)
        coordinator.start()
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
        self.coordinator = coordinator
    }
}