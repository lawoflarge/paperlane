import Testing
import Foundation
@testable import Paperlane

@MainActor
struct AppLockTests {
    private func freshDefaults() -> UserDefaults {
        let name = "applock-test-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func defaultsToUnlockedWhenDisabled() {
        let lock = AppLock(defaults: freshDefaults())
        #expect(lock.isEnabled == false)
        #expect(lock.state == .unlocked)
    }

    @Test func enablingThenBackgroundingLocks() {
        let lock = AppLock(defaults: freshDefaults())
        lock.setEnabled(true)
        #expect(lock.isEnabled)
        lock.lockIfEnabled()
        #expect(lock.state == .locked)
        lock.unlock()
        #expect(lock.state == .unlocked)
    }

    @Test func disablingUnlocks() {
        let lock = AppLock(defaults: freshDefaults())
        lock.setEnabled(true)
        lock.lockIfEnabled()
        lock.setEnabled(false)
        #expect(lock.state == .unlocked)
        #expect(lock.isEnabled == false)
    }
}
