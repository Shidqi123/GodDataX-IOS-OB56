import SwiftUI
import Combine
import Security

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentKey: String = ""
    @Published var hwid: String = ""
    @Published var deviceUserId: String = ""
    @Published var expiryDateString: String = AuthService.getOB57CountdownString()
    @Published var errorMessage: String?
    @Published var isVerifying: Bool = false
    public let sessionStartTime = Date()
    
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
    private let deviceUserStorage = "goddatax_device_user_id"
    
    static func getOB57CountdownString(dayLabel: String = "Hari") -> String {
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 11
        comps.day = 27
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        if let target = calendar.date(from: comps) {
            let diff = Int(target.timeIntervalSince(Date()))
            if diff > 0 {
                let days = diff / 86400
                let hours = (diff % 86400) / 3600
                let minutes = (diff % 3600) / 60
                let seconds = diff % 60
                if days > 0 {
                    return String(format: "%d %@ %02d:%02d:%02d", days, dayLabel, hours, minutes, seconds)
                } else {
                    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                }
            }
        }
        return "00:00:00"
    }
    
    func getLiveCountdownString(dayLabel: String = "Hari") -> String {
        if !expiryDateString.isEmpty && !expiryDateString.contains("OB56") && !expiryDateString.contains("OB57") && !expiryDateString.contains("Hari") && !expiryDateString.contains("Days") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let targetDate = formatter.date(from: expiryDateString) {
                let diff = Int(targetDate.timeIntervalSince(Date()))
                if diff > 0 {
                    let days = diff / 86400
                    let hours = (diff % 86400) / 3600
                    let minutes = (diff % 3600) / 60
                    let seconds = diff % 60
                    if days > 0 {
                        return String(format: "%d %@ %02d:%02d:%02d", days, dayLabel, hours, minutes, seconds)
                    } else {
                        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                    }
                } else {
                    return "Kedaluwarsa"
                }
            }
        }
        return AuthService.getOB57CountdownString(dayLabel: dayLabel)
    }
    
    init() {
        self.hwid = getOrGenerateHWID()
        self.deviceUserId = getOrGenerateDeviceUserId()
        self.expiryDateString = AuthService.getOB57CountdownString()
        checkStoredSession()
        syncUserWithFirebase()
    }
    
    func getOrGenerateHWID() -> String {
        // 1. Check iOS Keychain (persists across app uninstall and reinstall on this device!)
        if let keychainHWID = KeychainHelper.load(key: hwidStorage), !keychainHWID.isEmpty {
            UserDefaults.standard.set(keychainHWID, forKey: hwidStorage)
            return keychainHWID
        }
        
        // 2. Check UserDefaults
        if let stored = UserDefaults.standard.string(forKey: hwidStorage), !stored.isEmpty {
            KeychainHelper.save(key: hwidStorage, value: stored)
            return stored
        }
        
        // 3. Generate stable hardware ID based on vendor ID or persistent UUID
        let vendorId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let prefix = "GDX-IOS"
        let shortId = String(vendorId.prefix(12)).uppercased()
        let newHWID = "\(prefix)-\(shortId)"
        
        // Persist to Keychain and UserDefaults
        KeychainHelper.save(key: hwidStorage, value: newHWID)
        UserDefaults.standard.set(newHWID, forKey: hwidStorage)
        return newHWID
    }
    
    func getOrGenerateDeviceUserId() -> String {
        // 1. Check iOS Keychain (persists across uninstall/reinstall!)
        if let keychainUser = KeychainHelper.load(key: deviceUserStorage), !keychainUser.isEmpty {
            UserDefaults.standard.set(keychainUser, forKey: deviceUserStorage)
            return keychainUser
        }
        
        // 2. Check UserDefaults
        if let stored = UserDefaults.standard.string(forKey: deviceUserStorage), !stored.isEmpty {
            KeychainHelper.save(key: deviceUserStorage, value: stored)
            return stored
        }
        
        // 3. Generate deterministic user ID derived directly from the persistent HWID
        // This ensures that even across fresh reinstalls, the exact same User ID is produced!
        let clean = self.hwid.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "GDXIOS", with: "").lowercased()
        let suffix = clean.count >= 8 ? String(clean.prefix(8)) : "00b9987d"
        let generated = "user-\(suffix)"
        
        // Persist to Keychain and UserDefaults
        KeychainHelper.save(key: deviceUserStorage, value: generated)
        UserDefaults.standard.set(generated, forKey: deviceUserStorage)
        return generated
    }
    
    /// Syncs user with Firebase, locks 1 Device 1 User, and logs out user if OB56 expired or upgraded to OB57
    func syncUserWithFirebase() {
        let cleanBaseURL = firebaseDatabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !cleanBaseURL.isEmpty else { return }
        
        // 1. Check Global App Config (OB56 vs OB57 auto-logout)
        if let configURL = URL(string: "\(cleanBaseURL)/app_config.json") {
            var req = URLRequest(url: configURL)
            req.httpMethod = "GET"
            req.timeoutInterval = 3.0
            URLSession.shared.dataTask(with: req) { [weak self] data, res, err in
                guard let self = self, let data = data, err == nil,
                      let httpRes = res as? HTTPURLResponse, httpRes.statusCode == 200,
                      let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return }
                
                // If active_version in Firebase is OB57 (next update), force logout!
                if let activeVer = json["active_version"] as? String, activeVer.uppercased() != "OB56" {
                    DispatchQueue.main.async {
                        self.logout()
                        self.errorMessage = "Aplikasi versi OB56 telah kedaluwarsa. Silakan perbarui ke \(activeVer)!"
                    }
                    return
                }
            }.resume()
        }
        
        // 2. Query /users/{deviceUserId}.json to enforce 1 Device 1 User lock and fetch expiry
        guard let userURL = URL(string: "\(cleanBaseURL)/users/\(self.deviceUserId).json") else { return }
        var userReq = URLRequest(url: userURL)
        userReq.httpMethod = "GET"
        userReq.timeoutInterval = 3.0
        
        URLSession.shared.dataTask(with: userReq) { [weak self] data, res, err in
            guard let self = self, let data = data, err == nil,
                  let httpRes = res as? HTTPURLResponse, httpRes.statusCode == 200 else { return }
            
            let rawStr = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if rawStr == "null" || rawStr.isEmpty {
                // User does not exist yet: auto-register to Firebase immediately
                self.recordUserInFirebase(key: self.currentKey)
                return
            }
            
            guard let userDict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return }
            
            // Check status (banned / expired)
            if let status = userDict["status"] as? String {
                if status.lowercased() == "expired" {
                    DispatchQueue.main.async {
                        self.logout()
                        self.errorMessage = "Masa aktif lisensi OB56 Anda telah berakhir."
                    }
                    return
                } else if status.lowercased() == "banned" {
                    DispatchQueue.main.async {
                        self.logout()
                        self.errorMessage = "Akun/Device Anda telah dinonaktifkan."
                    }
                    return
                }
            }
            
            // Check 1 Device 1 User lock: verify locked_hwid matches this iPhone's HWID
            if let lockedHwid = userDict["locked_hwid"] as? String, !lockedHwid.isEmpty, lockedHwid != "GDX-IOS-DEFAULT" {
                if lockedHwid != self.hwid {
                    DispatchQueue.main.async {
                        self.logout()
                        self.errorMessage = "User ID ini terkunci pada perangkat lain (1 Device 1 User)!"
                    }
                    return
                }
            }
            
            // Update expiry display: show countdown to OB57
            if let exp = userDict["expiry"] as? String, !exp.isEmpty {
                DispatchQueue.main.async {
                    if exp.uppercased() == "OB56" || exp.uppercased().contains("OB56") {
                        self.expiryDateString = AuthService.getOB57CountdownString()
                    } else {
                        self.expiryDateString = exp
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.expiryDateString = AuthService.getOB57CountdownString()
                }
            }
            
            // Keep device active record up to date in Firebase
            self.recordUserInFirebase(key: self.currentKey)
        }.resume()
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
        self.syncUserWithFirebase()
        
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
    
    /// Records iOS user login & HWID into Firebase Realtime Database: /users/{deviceUserId}.json
    func recordUserInFirebase(key: String = "") {
        let cleanBaseURL = firebaseDatabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !cleanBaseURL.isEmpty, let userUrl = URL(string: "\(cleanBaseURL)/users/\(self.deviceUserId).json") else { return }
        
        let formatter = ISO8601DateFormatter()
        let now = formatter.string(from: Date())
        
        let payload: [String: Any] = [
            "hwid": self.hwid,
            "locked_hwid": self.hwid,
            "device_user_id": self.deviceUserId,
            "license_key": key.isEmpty ? (self.currentKey.isEmpty ? "OB56VIP" : self.currentKey) : key,
            "expiry": self.expiryDateString,
            "status": "active",
            "last_login": now,
            "platform": "iOS",
            "version": "OB56",
            "device_model": UIDevice.current.model,
            "system_version": UIDevice.current.systemVersion
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else { return }
        
        var userReq = URLRequest(url: userUrl)
        userReq.httpMethod = "PATCH"
        userReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        userReq.httpBody = httpBody
        userReq.timeoutInterval = 5.0
        URLSession.shared.dataTask(with: userReq) { _, _, _ in }.resume()
        
        if let hwidUrl = URL(string: "\(cleanBaseURL)/users/\(self.hwid).json") {
            var hwidReq = URLRequest(url: hwidUrl)
            hwidReq.httpMethod = "PATCH"
            hwidReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
            hwidReq.httpBody = httpBody
            hwidReq.timeoutInterval = 5.0
            URLSession.shared.dataTask(with: hwidReq) { _, _, _ in }.resume()
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: authKeyStorage)
        self.currentKey = ""
        self.isAuthenticated = false
    }
}

// MARK: - iOS Keychain Persistent Storage (Survives App Delete & Reinstall)
struct KeychainHelper {
    static let service = "com.goddatax.ios.device"
    
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Remove existing item if any
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add item with AccessibleAfterFirstUnlockThisDeviceOnly to ensure it stays on this physical device
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
