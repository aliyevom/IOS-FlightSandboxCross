import Foundation
import CryptoKit

enum EmployeeRole {
    case admin, pilot, scheduler
}

class ApiGateway {
    static let shared = ApiGateway()

    private let encryptionKey: SymmetricKey

    private init() {
        // Example encryption key, should be securely stored and retrieved
        self.encryptionKey = SymmetricKey(size: .bits256)
    }

    func authenticateUser(username: String, password: String, role: EmployeeRole, completion: @escaping (Result<String, Error>) -> Void) {
        // Example authentication - replace with real authentication logic (e.g., OAuth, LDAP)
        if username == "admin" && password == "password" && role == .admin {
            let token = generateJWT(for: username, role: role)
            completion(.success(token))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])))
        }
    }

    private func generateJWT(for username: String, role: EmployeeRole) -> String {
        // Generate a JWT token (simplified example)
        let payload = "\(username):\(role)"
        let data = Data(payload.utf8)
        let encryptedData = try! ChaChaPoly.seal(data, using: encryptionKey).combined
        return encryptedData.base64EncodedString()
    }

    func sendRequest(to airline: Airline, endpoint: String, parameters: [String: String], authToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString: String
        
        switch airline {
        case .thy:
            urlString = "https://api.thy.com/\(endpoint)"
        case .flydubai:
            urlString = "https://api.flydubai.com/\(endpoint)"
        case .pegasus:
            urlString = "https://api.flypgs.com/\(endpoint)"
        case .wizzair:
            urlString = "https://api.wizzair.com/\(endpoint)"
        }

        guard var urlComponents = URLComponents(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization") // Add the authentication token

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }
        task.resume()
    }
}
