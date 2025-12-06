import Foundation
import UIKit

protocol ImageCacheProtocol {
    func image(forKey key: String) -> UIImage?
    func setImage(_ image: UIImage, forKey key: String)
}

final class ImageCache: ImageCacheProtocol {
    private let cache = NSCache<NSString, UIImage>()

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let cache: ImageCacheProtocol
    private let session: URLSession

    init(cache: ImageCacheProtocol, session: URLSession = .shared) {
        self.cache = cache
        self.session = session
    }

    func load(url: URL) {
        let key = url.absoluteString
        if let cached = cache.image(forKey: key) {
            image = cached
            return
        }
        Task {
            do {
                let (data, response) = try await session.data(from: url)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return }
                guard let img = UIImage(data: data) else { return }
                cache.setImage(img, forKey: key)
                await MainActor.run { self.image = img }
            } catch {}
        }
    }
}