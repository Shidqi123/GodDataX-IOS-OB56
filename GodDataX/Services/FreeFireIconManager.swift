import SwiftUI
import Combine

class FreeFireIconManager: ObservableObject {
    static let shared = FreeFireIconManager()
    
    @Published var ffImage: UIImage?
    @Published var ffMaxImage: UIImage?
    @Published var ffIconURL: URL?
    @Published var ffMaxIconURL: URL?
    @Published var isLoading: Bool = false
    
    private let ffCacheKey = "cached_ff_icon_url_v2"
    private let ffMaxCacheKey = "cached_ff_max_icon_url_v2"
    
    init() {
        // 1. Immediately load bundled high-res OB56 assets so there is zero delay
        if let ffBundled = UIImage(named: "FFLogo") {
            self.ffImage = ffBundled
        }
        if let ffMaxBundled = UIImage(named: "FFMaxLogo") {
            self.ffMaxImage = ffMaxBundled
        }
        
        // 2. Load cached URLs if any
        if let ffSaved = UserDefaults.standard.string(forKey: ffCacheKey), let url = URL(string: ffSaved) {
            self.ffIconURL = url
            downloadImage(from: url) { [weak self] img in
                if let img = img {
                    DispatchQueue.main.async { self?.ffImage = img }
                }
            }
        }
        if let ffMaxSaved = UserDefaults.standard.string(forKey: ffMaxCacheKey), let url = URL(string: ffMaxSaved) {
            self.ffMaxIconURL = url
            downloadImage(from: url) { [weak self] img in
                if let img = img {
                    DispatchQueue.main.async { self?.ffMaxImage = img }
                }
            }
        }
        
        // 3. Fetch real-time live artwork from App Store
        fetchLatestIcons()
    }
    
    func getImage(for bundleId: String) -> UIImage {
        if bundleId.contains("max") {
            return ffMaxImage ?? UIImage(named: "FFMaxLogo") ?? UIImage()
        } else {
            return ffImage ?? UIImage(named: "FFLogo") ?? UIImage()
        }
    }
    
    func fetchLatestIcons() {
        isLoading = true
        
        // 1. Free Fire Standard
        fetchAppStoreArtwork(urlString: AppConfig.ffLookupURL) { [weak self] artworkURL in
            guard let self = self, let artworkURL = artworkURL else { return }
            DispatchQueue.main.async {
                self.ffIconURL = artworkURL
                UserDefaults.standard.set(artworkURL.absoluteString, forKey: self.ffCacheKey)
            }
            self.downloadImage(from: artworkURL) { img in
                guard let img = img else { return }
                DispatchQueue.main.async {
                    self.ffImage = img
                }
            }
        }
        
        // 2. Free Fire MAX
        fetchAppStoreArtwork(urlString: AppConfig.ffMaxLookupURL) { [weak self] artworkURL in
            guard let self = self, let artworkURL = artworkURL else { return }
            DispatchQueue.main.async {
                self.ffMaxIconURL = artworkURL
                UserDefaults.standard.set(artworkURL.absoluteString, forKey: self.ffMaxCacheKey)
            }
            self.downloadImage(from: artworkURL) { img in
                guard let img = img else { return }
                DispatchQueue.main.async {
                    self.ffMaxImage = img
                }
            }
        }
    }
    
    private func fetchAppStoreArtwork(urlString: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstItem = results.first {
                    
                    if let artwork512 = firstItem["artworkUrl512"] as? String,
                       let resultURL = URL(string: artwork512) {
                        completion(resultURL)
                        return
                    } else if let artwork100 = firstItem["artworkUrl100"] as? String,
                              let resultURL = URL(string: artwork100) {
                        completion(resultURL)
                        return
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
            completion(nil)
        }.resume()
    }
    
    private func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
