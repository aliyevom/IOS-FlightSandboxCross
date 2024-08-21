import Foundation

class FlightScheduler {

    enum FlightSchedulerError: Error {
        case invalidResponse
        case requestFailed
        case decodingError
    }

    func scheduleFlight(for pilotID: String, on date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        // Prepare the request
        let dateFormatter = ISO8601DateFormatter()
        let flightDate = dateFormatter.string(from: date)

        guard let url = URL() else {
            completion(.failure(FlightSchedulerError.invalidResponse))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["pilotID": pilotID, "flightDate": flightDate]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(FlightSchedulerError.requestFailed))
                return
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(FlightSchedulerError.decodingError))
                return
            }

            completion(.success(responseString))
        }
        task.resume()
    }
}
