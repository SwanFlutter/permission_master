class GetStorage {
    private let userDefaults = UserDefaults.standard
    
    func write(_ key: String, value: Any) throws {
        if JSONSerialization.isValidJSONObject([key: value]) {
            userDefaults.set(value, forKey: key)
        } else {
            throw NSError(domain: "com.permission_master", code: 1, userInfo: [NSLocalizedDescriptionKey: "Value is not JSON serializable"])
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