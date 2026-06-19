import Foundation
import LocalAuthentication
import Observation

/// Optional biometric / passcode lock on the library (free, privacy-first). The
/// enabled flag persists in UserDefaults; the lock state machine is unit-tested,
/// while the biometric evaluation itself is device-only.
@MainActor
@Observable
final class AppLock {
    enum LockState: Equatable { case unlocked, locked }

    private(set) var state: LockState
    private let defaults: UserDefaults
    private let enabledKey = "appLockEnabled"

    var isEnabled: Bool { defaults.bool(forKey: enabledKey) }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        state = defaults.bool(forKey: "appLockEnabled") ? .locked : .unlocked
    }

    func setEnabled(_ on: Bool) {
        defaults.set(on, forKey: enabledKey)
        if !on { state = .unlocked }
    }

    /// Re-lock when the app backgrounds (no-op if disabled).
    func lockIfEnabled() { if isEnabled { state = .locked } }

    func unlock() { state = .unlocked }

    /// Device-only biometric/passcode prompt. Unlocks on success, or when no policy
    /// is available, so the Simulator / passcode-less devices are never bricked.
    func authenticate() async {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            state = .unlocked
            return
        }
        let success = (try? await context.evaluatePolicy(
            .deviceOwnerAuthentication, localizedReason: "Unlock your scans")) ?? false
        if success { state = .unlocked }
    }
}
