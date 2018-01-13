import Foundation
import UIKit

extension UserDefaults {
    func bool(key: String, defaultValue: Bool) -> Bool {
        if (self.object(forKey: key) == nil) {
            return defaultValue
        }
        return self.bool(forKey: key)
    }

    func string(key: String, defaultValue: String?) -> String? {
        if (self.object(forKey: key) == nil) {
            return defaultValue
        }
        return self.string(forKey: key)
    }

    func integer(key: String, defaultValue: Int) -> Int {
        if (self.object(forKey: key) == nil) {
            return defaultValue
        }
        return self.integer(forKey: key)
    }
}