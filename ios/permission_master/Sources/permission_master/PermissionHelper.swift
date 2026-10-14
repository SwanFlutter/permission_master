class PermissionHelper {
    static let shared = PermissionHelper()
    
    private let userDefaults = UserDefaults.standard
    private let maxRequestCount = 2
    private let permissionRequestCountPrefix = "permission_request_count_"
    
    private init() {}
    
    func canRequestPermission(for permission: String) -> Bool {
        let key = permissionRequestCountPrefix + permission
        let count = userDefaults.integer(forKey: key)
        return count < maxRequestCount
    }
    
    func incrementRequestCount(for permission: String) {
        let key = permissionRequestCountPrefix + permission
        let currentCount = userDefaults.integer(forKey: key)
        userDefaults.set(currentCount + 1, forKey: key)
    }
    
    func resetRequestCount(for permission: String) {
        let key = permissionRequestCountPrefix + permission
        userDefaults.removeObject(forKey: key)
    }
}

enum PermissionStatus: String {
    case granted = "GRANTED"
    case denied = "DENIED"
    case permanentlyDenied = "PERMANENTLY_DENIED"
    case notDetermined = "NOT_DETERMINED"
}