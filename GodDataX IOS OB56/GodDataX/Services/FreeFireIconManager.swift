import SwiftUI
import Combine

class FreeFireIconManager: ObservableObject {
    static let shared = FreeFireIconManager()
    
    @Published var ffIconURL: URL?
    @Published var ffMaxIconURL: URL?
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date?
    
    private let ffCacheKey = "cached_ff_icon_url"
    private let ffMaxCacheKey = "cached_ff_max_icon_url"
    
    init() {
        // Load cached URLs first if available
        if let ffSaved = UserDefaults.standard.string(forKey: ffCacheKey), let url = URL(string: ffSaved) {
            self.ffIconURL = url
        }
        if let ffMaxSaved = UserDefaults.standard.string(forKey: ffMaxCacheKey), let url = URL(string: ffMaxSaved) {
            self.ffMaxIconURL = url
        }
        
        // Fetch latest live icons from App Store in background
        fetchLatestIcons()
    }
    
    /// Fetches real-time latest official App Store icons for Free Fire and Free Fire MAX
    func fetchLatestIcons() {
        isLoading = true
        
        let dispatchGroup = DispatchGroup()
        
        // 1. Fetch Free Fire Standard
        dispatchGroup.enter()
        fetchAppStoreArtwork(urlString: AppConfig.ffLookupURL) { [weak self] artworkURL in
            DispatchQueue.main.async {
                if let artworkURL = artworkURL {
                    self?.ffIconURL = artworkURL
                    UserDefaults.standard.set(artworkURL.absoluteString, forKey: self?.ffCacheKey ?? "")
                }
                dispatchGroup.leave()
            }
        }
        
        // 2. Fetch Free Fire MAX
        dispatchGroup.enter()
        fetchAppStoreArtwork(urlString: AppConfig.ffMaxLookupURL) { [weak self] artworkURL in
            DispatchQueue.main.async {
                if let artworkURL = artworkURL {
                    self?.ffMaxIconURL = artworkURL
                    UserDefaults.standard.set(artworkURL.absoluteString, forKey: self?.ffMaxCacheKey ?? "")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.isLoading = false
            self?.lastUpdated = Date()
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
                    
                    // App Store provides high-res artworkUrl512
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
}
