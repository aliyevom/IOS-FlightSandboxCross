import GRPC
import NIO
import Foundation

class FlightSchedulerClient {
    private let client: flightscheduler_FlightSchedulerClient
    private var authToken: String?

    init(authToken: String? = nil) {
        self.authToken = authToken
        
        // Setup the gRPC channel with TLS encryption
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let configuration = ClientConnection.Configuration(
            target: .hostAndPort("localhost", 50051),
            eventLoopGroup: group,
            tls: .init() // Enable TLS
        )
        let channel = ClientConnection(configuration: configuration)

        // Initialize the client
        self.client = flightscheduler_FlightSchedulerClient(channel: channel)
    }

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    func scheduleFlight(for pilotID: String, on date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        guard let authToken = authToken else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No auth token provided"])))
            return
        }

        // Format the date as ISO 8601
        let dateFormatter = ISO8601DateFormatter()
        let flightDate = dateFormatter.string(from: date)

        // Create the request
        var request = flightscheduler_ScheduleFlightRequest()
        request.pilotID = pilotID
        request.flightDate = flightDate

        // Add authentication token to the request metadata
        var callOptions = CallOptions()
        callOptions.customMetadata.add(name: "Authorization", value: "Bearer \(authToken)")

        // Call the gRPC method
        let call = client.scheduleFlight(request, callOptions: callOptions)

        call.response.whenComplete { result in
            switch result {
            case .success(let response):
                completion(.success(response.confirmationMessage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
