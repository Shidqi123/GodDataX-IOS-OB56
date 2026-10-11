import SwiftUI
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentKey: String = ""
    @Published var hwid: String = ""
    @Published var errorMessage: String?
    @Published var isVerifying: Bool = false
    
    // Default Firebase Realtime Database URL (can be customized)
    @AppStorage("firebase_db_url") var firebaseDatabaseURL: String = "https://goddatax-ios-default-rtdb.firebaseio.com"
    
    // Offline pre-approved keys list for instant access & fallback
    private let validKeys: Set<String> = [
        "SAIKUTO",
        "SAIFREE",
        "TESTKEY",
        "OBSIDIAN",
        "PIPCOV",
        "CLASSMAP",
        "SAIFREE2024",
        "VIPACCESS",
        "LIFETIME",
        "TEATKEY",
        "KUT0123",
        "OB56VIP",
        "OB56GODDATAX",
        "IOSVIP"
    ]
    
    private let authKeyStorage = "goddatax_saved_license"
    private let hwidStorage = "goddatax_device_hwid"
    
    init() {
        self.hwid = getOrGenerateHWID()
        checkStoredSession()
    }
    
    func getOrGenerateHWID() -> String {
        if let stored = UserDefaults.standard.string(forKey: hwidStorage) {
            return stored
        }
        
        let vendorId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let prefix = "GDX-IOS"
        let shortId = String(vendorId.prefix(12)).uppercased()
        let newHWID = "\(prefix)-\(shortId)"
        
        UserDefaults.standard.set(newHWID, forKey: hwidStorage)
        return newHWID
    }
    
    private func checkStoredSession() {
        if let savedKey = UserDefaults.standard.string(forKey: authKeyStorage), !savedKey.isEmpty {
            self.currentKey = savedKey
            self.isAuthenticated = true
        }
    }
    
    func login(key: String, completion: @escaping (Bool, String) -> Void) {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmedKey.isEmpty else {
            self.errorMessage = "Silakan masukkan lisensi"
            completion(false, "Silakan masukkan lisensi")
            return
        }
        
        isVerifying = true
        errorMessage = nil
        
        // 1. First, attempt Realtime Database verification via Firebase REST API
        verifyWithFirebase(key: trimmedKey) { [weak self] isFirebaseValid, firebaseMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if isFirebaseValid {
                    self.acceptLogin(key: trimmedKey, completion: completion)
                } else if self.validKeys.contains(trimmedKey) {
                    // 2. Fallback to valid offline keys list
                    self.acceptLogin(key: trimmedKey, completion: completion)
                } else {
                    self.isVerifying = false
                    let errMsg = "Lisensi tidak valid atau kadaluarsa"
                    self.errorMessage = errMsg
                    completion(false, errMsg)
                }
            }
        }
    }
    
    private func acceptLogin(key: String, completion: @escaping (Bool, String) -> Void) {
        self.isVerifying = false
        self.currentKey = key
        self.isAuthenticated = true
        UserDefaults.standard.set(key, forKey: self.authKeyStorage)
        
        // Register / record user session in Firebase Database asynchronously
        self.recordUserInFirebase(key: key)
        
        completion(true, "Akses Lisensi Diterima")
    }
    
    /// Queries Firebase Realtime Database REST API for license status
    private func verifyWithFirebase(key: String, completion: @escaping (Bool, String) -> Void) {
        let cleanBaseURL = firebaseDatabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(cleanBaseURL)/licenses/\(key).json") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 4.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  let jsonString = String(data: data, encoding: .utf8),
                  jsonString != "null" else {
                completion(false, "Not found in Firebase")
                return
            }
            
            // If the key node exists and is not "null", or contains active status:
            if jsonString.contains("\"active\":false") || jsonString.contains("\"status\":\"expired\"") {
                completion(false, "License expired")
            } else {
                completion(true, "Valid from Firebase")
            }
        }.resume()
    }
    
    /// Records iOS user login & HWID into Firebase Realtime Database: /users/{hwid}.json
    private func recordUserInFirebase(key: String) {
        let cleanBaseURL = firebaseDatabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(cleanBaseURL)/users/\(self.hwid).json") else { return }
        
        let formatter = ISO8601DateFormatter()
        let now = formatter.string(from: Date())
        
        let payload: [String: Any] = [
            "hwid": self.hwid,
            "license_key": key,
            "last_login": now,
            "platform": "iOS",
            "version": "OB56",
            "device_model": UIDevice.current.model,
            "system_version": UIDevice.current.systemVersion
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.timeoutInterval = 5.0
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            // Registered in Firebase successfully
        }.resume()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: authKeyStorage)
        self.currentKey = ""
        self.isAuthenticated = false
    }
}
