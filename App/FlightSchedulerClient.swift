import GRPC
import NIO
import Foundation

class FlightSchedulerClient {

    private let client: flightscheduler_FlightSchedulerClient

    init() {
        // Setup the gRPC channel
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let channel = ClientConnection.insecure(group: group)
            .connect(host: "localhost", port: 50051)

        // Initialize the client
        self.client = flightscheduler_FlightSchedulerClient(channel: channel)
    }

    func scheduleFlight(for pilotID: String, on date: Date, completion: @escaping (Result<String, Error>) -> Void) {
        // Format the date as ISO 8601
        let dateFormatter = ISO8601DateFormatter()
        let flightDate = dateFormatter.string(from: date)

        // Create the request
        var request = flightscheduler_ScheduleFlightRequest()
        request.pilotID = pilotID
        request.flightDate = flightDate

        // Call the gRPC method
        let call = client.scheduleFlight(request)

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
