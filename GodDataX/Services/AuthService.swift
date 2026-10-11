import SwiftUI
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentKey: String = ""
    @Published var hwid: String = ""
    @Published var errorMessage: String?
    @Published var isVerifying: Bool = false
    
    // Offline pre-approved keys list (from keys.json + OB56 updates)
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
        "OB56GODDATAX"
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
            completion(false, "Masukkan lisensi Anda")
            return
        }
        
        isVerifying = true
        errorMessage = nil
        
        // Simulate secure verification delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            self.isVerifying = false
            
            if self.validKeys.contains(trimmedKey) {
                self.currentKey = trimmedKey
                self.isAuthenticated = true
                UserDefaults.standard.set(trimmedKey, forKey: self.authKeyStorage)
                completion(true, "Akses Lisensi OB56 Diterima!")
            } else {
                self.errorMessage = "Lisensi tidak valid atau kadaluarsa"
                completion(false, "Lisensi tidak valid atau kadaluarsa")
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: authKeyStorage)
        self.currentKey = ""
        self.isAuthenticated = false
    }
}
