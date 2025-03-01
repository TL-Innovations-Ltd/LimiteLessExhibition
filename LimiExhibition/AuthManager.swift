import Foundation

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated: Bool = false

    private let tokenKey = "authToken"
    private let expiryKey = "authTokenExpiry"

    private init() {
        self.isAuthenticated = isTokenValid()
    }

    func saveToken(_ token: String, expiryInSeconds: TimeInterval = 3600) {
        let expiryTime = Date().timeIntervalSince1970 + expiryInSeconds
        
        // Save values
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(expiryTime, forKey: expiryKey)
        UserDefaults.standard.synchronize()  // Ensure it's written immediately
        
        // Debugging logs
        print("🔹 Saved Token:", token)
        print("🔹 Expiry Time Set:", expiryTime)
        
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }



    func getToken() -> String? {
        if isTokenValid() {
            return UserDefaults.standard.string(forKey: tokenKey)
        } else {
            clearToken()
            return nil
        }
    }

    func isTokenValid() -> Bool {
        let expiryTime = UserDefaults.standard.double(forKey: expiryKey)
        let currentTime = Date().timeIntervalSince1970
        print("Token Expiry Time:", expiryTime, "Current Time:", currentTime)

        if expiryTime > currentTime {
            return true
        } else {
            print("Token expired. Clearing token...")
            clearToken()
            return false
        }
    }


    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: expiryKey)
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}
