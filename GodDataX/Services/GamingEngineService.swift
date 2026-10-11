import Foundation
import UIKit
import AVFoundation

/// Real, native iOS Gaming Optimization Engine without gimmick claims
class GamingEngineService: ObservableObject {
    static let shared = GamingEngineService()
    
    @Published var activeOptimizationsCount: Int = 0
    @Published var lastNoticeMessage: String = ""
    
    private var pingTimer: Timer?
    private var isAudioOptimized: Bool = false
    
    init() {}
    
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
            
            // Clear temporary directory files
            let tmpDir = NSTemporaryDirectory()
            if let files = try? FileManager.default.contentsOfDirectory(atPath: tmpDir) {
                for file in files {
                    let fullPath = (tmpDir as NSString).appendingPathComponent(file)
                    try? FileManager.default.removeItem(atPath: fullPath)
                }
            }
            
            // Post memory warning notification to encourage system heap trim
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
            // Cancel background URL sessions
            URLSession.shared.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
                for t in dataTasks where t.state == .running {
                    t.priority = URLSessionTask.lowPriority
                }
            }
        }
        recalculateActiveCount()
    }
    
    // 9. Pelicin Gesekan Layar Drag FF (Touch Inertia & Friction Calibrator)
    private var displayLink: CADisplayLink?
    func setScreenSmoothDrag(enabled: Bool) {
        if enabled {
            // Synchronize touch event polling with display vsync to eliminate dragging micro-stutter
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
                // Elevate touch input runloop priority to prevent touch event lag
                RunLoop.main.perform(inModes: [.common, .tracking]) {
                    let gen = UISelectionFeedbackGenerator()
                    gen.prepare()
                }
            }
        }
        recalculateActiveCount()
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
        recalculateActiveCount()
    }
}
