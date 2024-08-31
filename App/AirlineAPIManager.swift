import Foundation

class AirlineAPIManager {
    func fetchFlightDetails(for airline: Airline, flightNumber: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "flight/\(flightNumber)"

        ApiGateway.shared.sendRequest(to: airline, endpoint: endpoint, parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        completion(.success(json))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
