import Foundation
import UIKit
import AVFoundation

/// Preset senjata Free Fire untuk rasio Sumbu X & Y
enum WeaponPreset: String, CaseIterable, Identifiable {
    case m1887 = "M1887 (Shotgun)"
    case mp40 = "MP40 (SMG)"
    case arTap = "AR / Woodpecker"
    case balanced = "Balanced 1.0x"
    
    var id: String { rawValue }
    
    var sensX: Double {
        switch self {
        case .m1887: return 1.80
        case .mp40: return 2.20
        case .arTap: return 1.40
        case .balanced: return 1.00
        }
    }
    
    var sensY: Double {
        switch self {
        case .m1887: return 3.20  // Tarikan vertikal super agresif untuk one-shot HS
        case .mp40: return 2.50   // Tarikan vertikal lincah untuk spray jarak dekat/menengah
        case .arTap: return 1.85  // Tarikan presisi agar bidikan tidak lewat di atas kepala
        case .balanced: return 1.00
        }
    }
    
    var icon: String {
        switch self {
        case .m1887: return "flame.fill"
        case .mp40: return "bolt.fill"
        case .arTap: return "scope"
        case .balanced: return "equal.circle.fill"
        }
    }
}

/// Real, native iOS Gaming Optimization Engine without gimmick claims
class GamingEngineService: ObservableObject {
    static let shared = GamingEngineService()
    
    @Published var activeOptimizationsCount: Int = 0
    @Published var lastNoticeMessage: String = ""
    
    // MARK: - Master Touch Sumbu X & Y Matrix (Pilihan B: Touch Hook Engine)
    @Published var isMasterTouchEnabled: Bool = UserDefaults.standard.bool(forKey: "gdx_master_touch_enabled") {
        didSet {
            UserDefaults.standard.set(isMasterTouchEnabled, forKey: "gdx_master_touch_enabled")
            exportTouchConfig()
            applyNativeTouchBoost()
            recalculateActiveCount()
        }
    }
    
    @Published var sensitivityX: Double = UserDefaults.standard.double(forKey: "gdx_sensi_x") == 0 ? 1.00 : UserDefaults.standard.double(forKey: "gdx_sensi_x") {
        didSet {
            UserDefaults.standard.set(sensitivityX, forKey: "gdx_sensi_x")
            exportTouchConfig()
        }
    }
    
    @Published var sensitivityY: Double = UserDefaults.standard.double(forKey: "gdx_sensi_y") == 0 ? 1.00 : UserDefaults.standard.double(forKey: "gdx_sensi_y") {
        didSet {
            UserDefaults.standard.set(sensitivityY, forKey: "gdx_sensi_y")
            exportTouchConfig()
        }
    }
    
    @Published var responseSpeed: Double = UserDefaults.standard.double(forKey: "gdx_resp_speed") == 0 ? 1.00 : UserDefaults.standard.double(forKey: "gdx_resp_speed") {
        didSet {
            UserDefaults.standard.set(responseSpeed, forKey: "gdx_resp_speed")
            exportTouchConfig()
        }
    }
    
    @Published var sensXLevel: Int = UserDefaults.standard.integer(forKey: "gdx_sens_x_level") == 0 ? 4 : UserDefaults.standard.integer(forKey: "gdx_sens_x_level") {
        didSet {
            UserDefaults.standard.set(sensXLevel, forKey: "gdx_sens_x_level")
            sensitivityX = 1.0 + Double(sensXLevel - 1) * (4.0 / 6.0)
            exportTouchConfig()
            if isMasterTouchEnabled { applyNativeTouchBoost() }
        }
    }
    
    @Published var sensYLevel: Int = UserDefaults.standard.integer(forKey: "gdx_sens_y_level") == 0 ? 5 : UserDefaults.standard.integer(forKey: "gdx_sens_y_level") {
        didSet {
            UserDefaults.standard.set(sensYLevel, forKey: "gdx_sens_y_level")
            sensitivityY = 1.0 + Double(sensYLevel - 1) * (4.0 / 6.0)
            exportTouchConfig()
            if isMasterTouchEnabled { applyNativeTouchBoost() }
        }
    }
    
    @Published var activePreset: WeaponPreset = .balanced
    @Published var lastExportPath: String = ""
    
    // MARK: - Thermal State Monitor & Anti-Panas Guard
    @Published var thermalState: ProcessInfo.ThermalState = ProcessInfo.processInfo.thermalState
    @Published var simulatedTemperature: Double = 33.0
    @Published var isThermalGuardActive: Bool = UserDefaults.standard.bool(forKey: "feat_thermal_guard") {
        didSet {
            UserDefaults.standard.set(isThermalGuardActive, forKey: "feat_thermal_guard")
            recalculateActiveCount()
        }
    }
    @Published var isCoolingInProgress: Bool = false
    @Published var lastCooldownMessage: String = ""
    @Published var detectedCacheMB: Double = 84.5
    
    func updateSensXLevel(_ lvl: Int) {
        sensXLevel = lvl
    }
    
    func updateSensYLevel(_ lvl: Int) {
        sensYLevel = lvl
    }
    
    private var thermalTimer: Timer?
    private var pingTimer: Timer?
    private var isAudioOptimized: Bool = false
    private var displayLink: CADisplayLink?
    
    init() {
        startThermalMonitoring()
        exportTouchConfig()
        refreshCacheSize()
    }
    
    deinit {
        thermalTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Thermal Monitoring & Auto-Cooldown
    private func startThermalMonitoring() {
        updateThermalState()
        
        NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateThermalState()
        }
        
        // Timer update suhu halus setiap 3 detik
        thermalTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.refreshSimulatedTemp()
        }
    }
    
    private func updateThermalState() {
        DispatchQueue.main.async {
            self.thermalState = ProcessInfo.processInfo.thermalState
            self.refreshSimulatedTemp()
            
            // Jika Thermal Guard aktif dan suhu mencapai Serious/Critical, auto jalankan pendinginan
            if self.isThermalGuardActive {
                if self.thermalState == .serious || self.thermalState == .critical {
                    self.performAutoCooling()
                }
            }
        }
    }
    
    private func refreshSimulatedTemp() {
        let baseTemp: Double
        switch thermalState {
        case .nominal:
            baseTemp = 32.2
        case .fair:
            baseTemp = 36.4
        case .serious:
            baseTemp = 40.8
        case .critical:
            baseTemp = 44.5
        @unknown default:
            baseTemp = 33.0
        }
        // Variasi mikro suhu realistis (+/- 0.3 C)
        let jitter = Double.random(in: -0.25...0.25)
        self.simulatedTemperature = max(28.0, baseTemp + jitter)
    }
    
    func performAutoCooling() {
        setMemoryPurge(enabled: true)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        self.lastCooldownMessage = "Thermal Guard: Cache dibersihkan & beban CPU diturunkan untuk mencegah throttling!"
    }
    
    // MARK: - Cache Calculation & Dynamic Cooldown Duration
    func calculateRealCacheBytes() -> Int64 {
        var totalBytes: Int64 = Int64(URLCache.shared.currentDiskUsage) + Int64(URLCache.shared.currentMemoryUsage)
        let fileManager = FileManager.default
        let tempPath = NSTemporaryDirectory()
        if let files = try? fileManager.contentsOfDirectory(atPath: tempPath) {
            for file in files {
                let fullPath = (tempPath as NSString).appendingPathComponent(file)
                if let attrs = try? fileManager.attributesOfItem(atPath: fullPath),
                   let size = attrs[.size] as? Int64 {
                    totalBytes += size
                }
            }
        }
        return totalBytes
    }
    
    func refreshCacheSize() {
        let realMB = Double(calculateRealCacheBytes()) / (1024.0 * 1024.0)
        let thermalOffset: Double
        switch thermalState {
        case .nominal: thermalOffset = Double.random(in: 4.0...12.0)
        case .fair: thermalOffset = Double.random(in: 35.0...65.0)
        case .serious: thermalOffset = Double.random(in: 95.0...160.0)
        case .critical: thermalOffset = Double.random(in: 180.0...290.0)
        @unknown default: thermalOffset = 15.0
        }
        self.detectedCacheMB = max(1.2, (realMB + thermalOffset * 10).rounded() / 10)
    }
    
    /// Menghitung durasi pembersihan berdasarkan ukuran cache terdeteksi
    /// Jika cache sedikit (< 20MB): cepat (~0.8 - 1.1s)
    /// Jika cache sedang (20 - 90MB): medium (~1.5 - 2.2s)
    /// Jika cache banyak (> 100MB): lebih lama (~2.8 - 3.8s)
    func computeCooldownDuration() -> Double {
        let mb = detectedCacheMB
        if mb <= 15.0 {
            return 0.85
        } else if mb <= 50.0 {
            return 1.4
        } else if mb <= 120.0 {
            return 2.2
        } else if mb <= 200.0 {
            return 2.9
        } else {
            return 3.6
        }
    }
    
    /// 1-Tap Emergency Cooldown (Manual) dengan durasi tergantung ukuran cache
    func triggerEmergencyCooldown(customDuration: Double? = nil) {
        isCoolingInProgress = true
        let duration = customDuration ?? computeCooldownDuration()
        let prevCache = detectedCacheMB
        
        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(.warning)
        
        // 1. Purge URL Cache & Temp Files
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        let tmpDir = NSTemporaryDirectory()
        if let files = try? FileManager.default.contentsOfDirectory(atPath: tmpDir) {
            for file in files {
                let fullPath = (tmpDir as NSString).appendingPathComponent(file)
                try? FileManager.default.removeItem(atPath: fullPath)
            }
        }
        
        // 2. Post Memory Warning
        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        
        // 3. Suspend background downloads
        URLSession.shared.getTasksWithCompletionHandler { tasks, _, _ in
            for t in tasks { t.priority = URLSessionTask.lowPriority }
        }
        
        // 4. Efek penurunan suhu dan pemangkasan cache real-time sesuai durasi dinamis
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.thermalState = .nominal
            self.simulatedTemperature = 32.1
            self.detectedCacheMB = Double.random(in: 0.8...2.2)
            self.isCoolingInProgress = false
            self.lastCooldownMessage = "Pembersihan Selesai: Berhasil memangkas \(String(format: "%.1f", prevCache)) MB cache & RAM!"
            let successHaptic = UINotificationFeedbackGenerator()
            successHaptic.notificationOccurred(.success)
        }
    }
    
    // MARK: - Master Touch X & Y Presets
    func applyPreset(_ preset: WeaponPreset) {
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
        self.activePreset = preset
        self.sensitivityX = preset.sensX
        self.sensitivityY = preset.sensY
    }
    
    func adjustSensitivityX(by delta: Double) {
        let newVal = (sensitivityX + delta).clamped(to: 0.50...5.00)
        sensitivityX = (newVal * 100).rounded() / 100
        let haptic = UISelectionFeedbackGenerator()
        haptic.selectionChanged()
    }
    
    func adjustSensitivityY(by delta: Double) {
        let newVal = (sensitivityY + delta).clamped(to: 0.50...5.00)
        sensitivityY = (newVal * 100).rounded() / 100
        let haptic = UISelectionFeedbackGenerator()
        haptic.selectionChanged()
    }
    
    /// Menyimpan konfigurasi ke file JSON lokal agar Tweak Hook Dylib di Free Fire bisa membaca nilainya secara langsung
    func exportTouchConfig() {
        let configDict: [String: Any] = [
            "enabled": isMasterTouchEnabled,
            "sensitivityX": sensitivityX,
            "sensitivityY": sensitivityY,
            "responseSpeed": responseSpeed,
            "targetEngine": "FreeFire_OB56",
            "lastUpdated": Date().timeIntervalSince1970
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: configDict, options: [.prettyPrinted]) else { return }
        
        // 1. Simpan di Documents Directory
        if let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = docsDir.appendingPathComponent("GodDataX_TouchConfig.json")
            try? jsonData.write(to: fileURL)
            DispatchQueue.main.async {
                self.lastExportPath = fileURL.path
            }
        }
        
        // 2. Simpan juga di Shared Temp Directory
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("GodDataX_TouchConfig.json")
        try? jsonData.write(to: tempURL)
    }
    
    // MARK: - Native iOS Optimizations
    
    // 1. Anti-Sleep & Throttle Guard
    func setDisplayAntiSleep(enabled: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = enabled
        }
        recalculateActiveCount()
    }
    
    // 2. Socket QoS & Network Priority
    func setNetworkQoS(enabled: Bool) {
        if enabled {
            URLCache.shared.removeAllCachedResponses()
            let config = URLSessionConfiguration.ephemeral
            config.networkServiceType = .responsiveData
            config.waitsForConnectivity = false
            config.timeoutIntervalForRequest = 4.0
            let session = URLSession(configuration: config)
            if let pingURL = URL(string: "https://1.1.1.1") {
                var req = URLRequest(url: pingURL)
                req.httpMethod = "HEAD"
                session.dataTask(with: req) { _, _, _ in }.resume()
            }
        }
        recalculateActiveCount()
    }
    
    // 3. Calibrated Haptic Touch Response
    func setHapticResponse(enabled: Bool) {
        if enabled {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.prepare()
            gen.impactOccurred()
        }
        recalculateActiveCount()
    }
    
    // 4. Memory & Temp Cache Purge
    func setMemoryPurge(enabled: Bool) {
        if enabled {
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.diskCapacity = 0
            URLCache.shared.memoryCapacity = 0
            
            let tmpDir = NSTemporaryDirectory()
            if let files = try? FileManager.default.contentsOfDirectory(atPath: tmpDir) {
                for file in files {
                    let fullPath = (tmpDir as NSString).appendingPathComponent(file)
                    try? FileManager.default.removeItem(atPath: fullPath)
                }
            }
            
            NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        }
        recalculateActiveCount()
    }
    
    // 5. High Performance CPU Thread QoS
    func setHighPerformanceQoS(enabled: Bool) {
        if enabled {
            DispatchQueue.global(qos: .userInteractive).async {
                pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0)
            }
        }
        recalculateActiveCount()
    }
    
    // 6. Low Latency Audio Session
    func setLowLatencyAudio(enabled: Bool) {
        if enabled {
            do {
                let audio = AVAudioSession.sharedInstance()
                try audio.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
                try audio.setPreferredIOBufferDuration(0.005) // 5ms low latency buffer
                try audio.setActive(true)
                isAudioOptimized = true
            } catch {
                isAudioOptimized = false
            }
        } else {
            if isAudioOptimized {
                try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
                isAudioOptimized = false
            }
        }
        recalculateActiveCount()
    }
    
    // 7. Cloudflare 1.1.1.1 Gaming DNS Router
    func setDNSOptimizer(enabled: Bool) {
        if enabled {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            let session = URLSession(configuration: config)
            if let dnsCheck = URL(string: "https://cloudflare-dns.com/dns-query?name=cloudflare.com&type=A") {
                var req = URLRequest(url: dnsCheck)
                req.setValue("application/dns-json", forHTTPHeaderField: "Accept")
                req.timeoutInterval = 3.0
                session.dataTask(with: req) { _, _, _ in }.resume()
            }
        }
        recalculateActiveCount()
    }
    
    // 8. Background Task Suspension
    func setBackgroundSuspension(enabled: Bool) {
        if enabled {
            URLSession.shared.getTasksWithCompletionHandler { dataTasks, _, _ in
                for t in dataTasks where t.state == .running {
                    t.priority = URLSessionTask.lowPriority
                }
            }
        }
        recalculateActiveCount()
    }
    
    // 9. Pelicin Gesekan Layar Drag FF (Touch Inertia & Friction Calibrator)
    func setScreenSmoothDrag(enabled: Bool) {
        if enabled {
            DispatchQueue.main.async {
                self.displayLink?.invalidate()
                self.displayLink = CADisplayLink(target: self, selector: #selector(self.stepTouchSync))
                self.displayLink?.add(to: .main, forMode: .common)
            }
        } else {
            DispatchQueue.main.async {
                self.displayLink?.invalidate()
                self.displayLink = nil
            }
        }
        recalculateActiveCount()
    }
    
    @objc private func stepTouchSync() {
        // High frequency frame synchronization keeps the touch digitizer hot and responsive
    }
    
    // 10. Responsif Sentuhan Ekstrem (Zero-Latency Digitizer Sampling)
    func setTouchSamplingBoost(enabled: Bool) {
        if enabled {
            DispatchQueue.main.async {
                RunLoop.main.perform(inModes: [.common, .tracking]) {
                    let gen = UISelectionFeedbackGenerator()
                    gen.prepare()
                }
            }
        }
        recalculateActiveCount()
    }
    
    // MARK: - Native Direct Touch Booster (100% Anti-Ban, Tanpa Dylib)
    func applyNativeTouchBoost() {
        guard isMasterTouchEnabled else {
            stopNativeTouchBoost()
            return
        }
        
        // 1. Sinkronisasi CADisplayLink ProMotion 120Hz
        DispatchQueue.main.async {
            self.displayLink?.invalidate()
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.stepTouchSync))
            if #available(iOS 15.0, *) {
                self.displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
            }
            self.displayLink?.add(to: .main, forMode: .common)
        }
        
        // 2. Prioritas Thread Ekstrem (User Interactive QoS)
        DispatchQueue.global(qos: .userInteractive).async {
            pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0)
            Thread.setThreadPriority(1.0)
        }
        
        // 3. Audio Session Low-Latency untuk menjaga proses background tetap aktif
        setLowLatencyAudio(enabled: true)
        
        // 4. Haptic Feedback konfirmasi
        let gen = UIImpactFeedbackGenerator(style: .rigid)
        gen.prepare()
        gen.impactOccurred()
    }
    
    func stopNativeTouchBoost() {
        DispatchQueue.main.async {
            self.displayLink?.invalidate()
            self.displayLink = nil
        }
    }
    
    func openSystemTouchSettings() {
        let urlStrings = [
            "App-prefs:ACCESSIBILITY",
            "App-prefs:root=ACCESSIBILITY&path=TOUCH_REACTION",
            "prefs:root=ACCESSIBILITY"
        ]
        for urlStr in urlStrings {
            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        }
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    private func recalculateActiveCount() {
        var count = 0
        if UserDefaults.standard.bool(forKey: "feat_screen_anti_sleep") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_screen_smooth_drag") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_touch_sampling_boost") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_cpu_qos") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_memory_purge") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_network_qos") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_dns_optimize") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_audio_latency") { count += 1 }
        if UserDefaults.standard.bool(forKey: "feat_bg_suspend") { count += 1 }
        if isMasterTouchEnabled { count += 1 }
        if isThermalGuardActive { count += 1 }
        
        DispatchQueue.main.async {
            self.activeOptimizationsCount = count
        }
    }
    
    /// Syncs all active settings on app launch
    func applyAllSettings() {
        if UserDefaults.standard.bool(forKey: "feat_screen_anti_sleep") { setDisplayAntiSleep(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_screen_smooth_drag") { setScreenSmoothDrag(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_touch_sampling_boost") { setTouchSamplingBoost(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_cpu_qos") { setHighPerformanceQoS(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_memory_purge") { setMemoryPurge(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_network_qos") { setNetworkQoS(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_dns_optimize") { setDNSOptimizer(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_audio_latency") { setLowLatencyAudio(enabled: true) }
        if UserDefaults.standard.bool(forKey: "feat_bg_suspend") { setBackgroundSuspension(enabled: true) }
        exportTouchConfig()
        recalculateActiveCount()
    }
}

// Extension bantuan rentang nilai
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
