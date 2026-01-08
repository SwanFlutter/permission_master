import Foundation

class GetStorage {
    private let userDefaults = UserDefaults.standard
    
    func write(_ key: String, value: Any) throws {
        if JSONSerialization.isValidJSONObject([key: value]) {
            userDefaults.set(value, forKey: key)
        } else {
            // For simple types that might not be considered "JSON Object" at top level but are valid in UserDefaults
            // But let's stick to the iOS implementation logic first.
            // Actually, UserDefaults can store String, Int, Bool, etc. directly.
            // The iOS implementation checks JSONSerialization.isValidJSONObject([key: value]).
            // This wrapper [key: value] makes it a dictionary, which is a valid JSON object if value is valid.
            // So this check ensures 'value' is JSON serializable.
            userDefaults.set(value, forKey: key)
        }
    }
    
    func read(_ key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }
    
    func contains(_ key: String) -> Bool {
        return userDefaults.object(forKey: key) != nil
    }
    
    func remove(_ key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clear() {
        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
}
