import Foundation

enum Airline: String {
    case thy = "Turkish Airlines"
    case flydubai = "Flydubai"
    case pegasus = "Pegasus Airlines"
    case wizzair = "Wizz Air"
}

class ApiGateway {
    static let shared = ApiGateway()

    private init() {}

    func sendRequest(to airline: Airline, endpoint: String, parameters: [String: String], completion: @escaping (Result<Data, Error>) -> Void) {
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
