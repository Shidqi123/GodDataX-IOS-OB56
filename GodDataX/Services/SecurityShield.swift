import Foundation
import UIKit
import CryptoKit
import Darwin
import MachO

/// Sistem Keamanan Native GodDataX (Anti-Tamper, Anti-Crack & String Obfuscation)
final class SecurityShield {
    static let shared = SecurityShield()
    
    private init() {}
    
    // MARK: - 1. Anti-Debugging Protection (ptrace & sysctl)
    /// Mencegah debugger (LLDB, GDB, Frida, Cycript) menempel pada proses aplikasi
    func enableAntiDebugging() {
        #if !DEBUG
        // 1. PTRACE PT_DENY_ATTACH (Nilai 31)
        typealias PtraceType = @convention(c) (CInt, pid_t, CInt, CInt) -> CInt
        let ptraceHandle = dlopen(nil, RTLD_GLOBAL)
        if let ptraceSym = dlsym(ptraceHandle, "ptrace") {
            let ptraceFunc = unsafeBitCast(ptraceSym, to: PtraceType.self)
            _ = ptraceFunc(31, 0, 0, 0) // PT_DENY_ATTACH
        }
        
        // 2. Sysctl P_TRACED Check
        if isDebuggerAttached() {
            // Segera keluar jika terdeteksi debugger aktif
            exit(0)
        }
        #endif
    }
    
    private func isDebuggerAttached() -> Bool {
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        if junk == 0 {
            return (info.kp_proc.p_flag & P_TRACED) != 0
        }
        return false
    }
    
    // MARK: - 2. Anti-Frida & Injected Dylib Scanner
    /// Mendeteksi hook / inject tools populer yang dipakai untuk mem-bypass lisensi
    func isTamperDetected() -> Bool {
        // Cek Environment Variable injeksi dinamis
        if let dyldInsert = getenv("DYLD_INSERT_LIBRARIES") {
            let str = String(cString: dyldInsert).lowercased()
            if str.contains("frida") || str.contains("cynject") || str.contains("sslkill") {
                return true
            }
        }
        
        // Cek image library yang sedang dimuat di memori
        let count = _dyld_image_count()
        for i in 0..<count {
            if let namePtr = _dyld_get_image_name(i) {
                let name = String(cString: namePtr).lowercased()
                if name.contains("fridagadget") || name.contains("frida-agent") || name.contains("substrate") && !name.contains("goddatax") {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - 3. XOR String Deobfuscator
    /// Mengubah array byte terenkripsi menjadi string asli di memori hanya saat dibutuhkan
    static func decrypt(bytes: [UInt8], key: UInt8 = 0x5A) -> String {
        let decryptedBytes = bytes.map { $0 ^ key }
        return String(bytes: decryptedBytes, encoding: .utf8) ?? ""
    }
    
    // MARK: - 4. SHA-256 Hasher
    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
