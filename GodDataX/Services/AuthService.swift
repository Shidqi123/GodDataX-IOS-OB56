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
    
    // Encrypted Firebase Realtime Database URL (XOR 0x5A) - string tidak terbaca di binary
    private static let encryptedDBURL: [UInt8] = [
        50, 46, 46, 42, 41, 96, 117, 117, 61, 53, 62, 62, 59, 46, 59, 34, 119, 51, 53, 41, 119, 62, 63, 60, 59, 47, 54, 46, 119, 40, 46, 62, 56, 116, 60, 51, 40, 63, 56, 59, 41, 63, 51, 53, 116, 57, 53, 55
    ]
    
    var firebaseDatabaseURL: String {
        return SecurityShield.decrypt(bytes: Self.encryptedDBURL, key: 0x5A)
    }
    
    // Offline pre-approved keys list (Disimpan dalam bentuk SHA-256 Hash - tidak bisa di-crack dari binary)
    private let validKeyHashes: Set<String> = [
        "dd317b098a4ef1b9685beaa30b26138b8a8487486243b2fa79a69b623c2b2ab9", // SAIKUTO
        "03aff1adbf9a43955a94ff4ba558e2186d6ad238e5fd4328df2baa4ef749c8ce", // SAIFREE
        "08eaa74f361516ef950fc2a7263d99fc2a3f624849b0a6cd3301c02f5f5db7e6", // OBSIDIAN
        "cde2d69a8d002dc8c6d44776f5c2c114f6d0d5454c47f520fd24b27349998669", // PIPCOV
        "44142f4822e4c64ea97cdc6881df740d25a3ee8ededd3e05e40e9ac46e9649c4", // CLASSMAP
        "13d6e50bff60038200b200d0a0a6bb26a2f6ceb9c2ee78c44797efc4601f1645", // SAIFREE2024
        "ad912e495db1b540788db9798fe0482b5ff88b48ba9f1de14d1f1a7e9e211823", // VIPACCESS
        "10412dbed2b6f4b0848579d9c9e694a5dc6042b47e7c2ed3b2a698d4c8b0d9e1", // LIFETIME
        "6f5208a8c95e88f8d94a3c139b50bd820573b31ae170ea3b09ae37f9ef4aa4fd", // KUT0123
        "7d9267984f3abd8d69ded1ed8fa5a538a115792cd3ca32764c7833fe813b2eb1", // OB56VIP
        "f151d30e9f55f5431942ead3929472930ca0f0f56e8e4a76b96f968c5202414f", // OB56GODDATAX
        "3045acd5deb43a5f1e1b6203af33fadd8b1b0d94d4fa14eadbd161c4b29fac6e"  // IOSVIP
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
    
    static let ob57TargetDate: Date = {
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 11
        comps.day = 27
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        return Calendar.current.date(from: comps) ?? Date(timeIntervalSince1970: 1795737600)
    }()
    
    static func isOB57Reached() -> Bool {
        return Date() >= ob57TargetDate
    }
    
    private var sessionMonitorTimer: Timer?
    
    init() {
        // Proteksi Anti-Debugging & Anti-Tamper
        SecurityShield.shared.enableAntiDebugging()
        if SecurityShield.shared.isTamperDetected() {
            exit(0)
        }
        
        self.hwid = getOrGenerateHWID()
        self.deviceUserId = getOrGenerateDeviceUserId()
        self.expiryDateString = AuthService.getOB57CountdownString()
        checkStoredSession()
        startSessionMonitoring()
        syncUserWithFirebase()
    }
    
    private func startSessionMonitoring() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkOB57Status()
            self?.syncUserWithFirebase()
        }
        
        sessionMonitorTimer?.invalidate()
        sessionMonitorTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.checkOB57Status()
            if self?.isAuthenticated == true {
                self?.syncUserWithFirebase()
            }
        }
    }
    
    func checkOB57Status() {
        if AuthService.isOB57Reached() {
            DispatchQueue.main.async {
                if self.isAuthenticated {
                    self.logout()
                    self.errorMessage = "Free Fire telah diperbarui ke OB57. Versi GodDataX OB56 telah kedaluwarsa otomatis."
                }
            }
        }
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
            
            // 3. Query /licenses/{currentKey}.json to verify 1 License 1 Device lock in real-time
            if !self.currentKey.isEmpty, let licenseURL = URL(string: "\(cleanBaseURL)/licenses/\(self.currentKey).json") {
                var licReq = URLRequest(url: licenseURL)
                licReq.httpMethod = "GET"
                licReq.timeoutInterval = 3.0
                URLSession.shared.dataTask(with: licReq) { [weak self] data, res, err in
                    guard let self = self, let data = data, err == nil,
                          let licDict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { return }
                    
                    if let lockedHwid = licDict["locked_hwid"] as? String, !lockedHwid.isEmpty {
                        if lockedHwid != self.hwid {
                            DispatchQueue.main.async {
                                self.logout()
                                self.errorMessage = "Lisensi Anda telah dipakai pada perangkat lain (1 License = 1 Perangkat)!"
                            }
                            return
                        }
                    }
                    if let status = licDict["status"] as? String, (status.lowercased() == "expired" || status.lowercased() == "banned") {
                        DispatchQueue.main.async {
                            self.logout()
                            self.errorMessage = "Lisensi telah dinonaktifkan atau kedaluwarsa."
                        }
                    }
                }.resume()
            }
            
            // Keep device active record up to date in Firebase
            self.recordUserInFirebase(key: self.currentKey)
        }.resume()
    }
    
    private func checkStoredSession() {
        if AuthService.isOB57Reached() {
            logout()
            self.errorMessage = "Free Fire telah diperbarui ke OB57. Versi GodDataX OB56 telah kedaluwarsa otomatis."
            return
        }
        
        if let savedKey = UserDefaults.standard.string(forKey: authKeyStorage), !savedKey.isEmpty {
            self.currentKey = savedKey
            self.isAuthenticated = true
        }
    }
    
    func login(key: String, completion: @escaping (Bool, String) -> Void) {
        if AuthService.isOB57Reached() {
            let msg = "Free Fire telah diperbarui ke OB57. GodDataX OB56 telah kedaluwarsa otomatis."
            self.errorMessage = msg
            completion(false, msg)
            return
        }
        
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmedKey.isEmpty else {
            self.errorMessage = "Silakan masukkan lisensi"
            completion(false, "Silakan masukkan lisensi")
            return
        }
        
        isVerifying = true
        errorMessage = nil
        
        // 1. Attempt Realtime Database verification via Firebase REST API
        verifyWithFirebase(key: trimmedKey) { [weak self] isFirebaseValid, firebaseMsg in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if isFirebaseValid {
                    self.lockLicenseToThisDevice(key: trimmedKey)
                    self.acceptLogin(key: trimmedKey, completion: completion)
                } else if firebaseMsg.contains("1 License = 1 Perangkat") || firebaseMsg.contains("terkunci pada perangkat lain") {
                    // STERN REJECTION: If already used by another device, REJECT!
                    self.isVerifying = false
                    self.errorMessage = firebaseMsg
                    completion(false, firebaseMsg)
                } else if self.validKeyHashes.contains(SecurityShield.sha256(trimmedKey)) {
                    // Pre-approved key: check if locked in Firebase or lock it now
                    self.checkPreApprovedKeyLock(key: trimmedKey) { isLockedToOther in
                        DispatchQueue.main.async {
                            if isLockedToOther {
                                self.isVerifying = false
                                let msg = "Lisensi ini sudah terkunci pada perangkat lain (1 License = 1 Perangkat)!"
                                self.errorMessage = msg
                                completion(false, msg)
                            } else {
                                self.lockLicenseToThisDevice(key: trimmedKey)
                                self.acceptLogin(key: trimmedKey, completion: completion)
                            }
                        }
                    }
                } else {
                    self.isVerifying = false
                    let errMsg = firebaseMsg.isEmpty ? "Lisensi tidak valid atau kadaluarsa" : firebaseMsg
                    self.errorMessage = errMsg
                    completion(false, errMsg)
                }
            }
        }
    }
    
    private func checkPreApprovedKeyLock(key: String, completion: @escaping (Bool) -> Void) {
        let cleanBaseURL = firebaseDatabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(cleanBaseURL)/licenses/\(key).json") else {
            completion(false)
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 3.0
        URLSession.shared.dataTask(with: req) { [weak self] data, res, err in
            guard let self = self, let data = data, err == nil,
                  let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let lockedHwid = dict["locked_hwid"] as? String, !lockedHwid.isEmpty else {
                completion(false)
                return
            }
            if lockedHwid != self.hwid {
                completion(true) // Locked to another device!
            } else {
                completion(false) // Locked to this device, permitted
            }
        }.resume()
    }
    
    func lockLicenseToThisDevice(key: String) {
        let cleanBaseURL = firebaseDatabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !cleanBaseURL.isEmpty, let url = URL(string: "\(cleanBaseURL)/licenses/\(key).json") else { return }
        
        let formatter = ISO8601DateFormatter()
        let now = formatter.string(from: Date())
        
        let payload: [String: Any] = [
            "locked_hwid": self.hwid,
            "locked_device_user": self.deviceUserId,
            "activated_at": now,
            "status": "active",
            "device_model": UIDevice.current.model,
            "version": "OB56"
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = httpBody
        req.timeoutInterval = 4.0
        URLSession.shared.dataTask(with: req) { _, _, _ in }.resume()
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
    
    /// Queries Firebase Realtime Database REST API for license status and checks 1 License 1 Device lock
    private func verifyWithFirebase(key: String, completion: @escaping (Bool, String) -> Void) {
        let cleanBaseURL = firebaseDatabaseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(cleanBaseURL)/licenses/\(key).json") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 4.0
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data, error == nil,
                  let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200,
                  let jsonString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  jsonString != "null", !jsonString.isEmpty else {
                completion(false, "Lisensi tidak ditemukan di database")
                return
            }
            
            if let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
                // 1. Check status (banned/expired)
                if let status = dict["status"] as? String, (status.lowercased() == "expired" || status.lowercased() == "banned") {
                    completion(false, "Lisensi telah kedaluwarsa atau dinonaktifkan")
                    return
                }
                if let active = dict["active"] as? Bool, !active {
                    completion(false, "Lisensi tidak aktif")
                    return
                }
                
                // 2. Strict 1 License 1 Device Lock
                if let lockedHwid = dict["locked_hwid"] as? String, !lockedHwid.isEmpty {
                    if lockedHwid != self.hwid {
                        completion(false, "Lisensi ini sudah terkunci pada perangkat lain (1 License = 1 Perangkat)!")
                        return
                    }
                } else if let boundDevice = dict["device_id"] as? String, !boundDevice.isEmpty {
                    if boundDevice != self.hwid && boundDevice != self.deviceUserId {
                        completion(false, "Lisensi ini sudah terkunci pada perangkat lain (1 License = 1 Perangkat)!")
                        return
                    }
                } else {
                    // Lock license to this device immediately
                    self.lockLicenseToThisDevice(key: key)
                }
                
                completion(true, "Akses Lisensi Diterima")
            } else {
                if jsonString.contains("\"active\":false") || jsonString.contains("\"status\":\"expired\"") {
                    completion(false, "Lisensi telah kedaluwarsa")
                } else {
                    self.lockLicenseToThisDevice(key: key)
                    completion(true, "Akses Lisensi Diterima")
                }
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
