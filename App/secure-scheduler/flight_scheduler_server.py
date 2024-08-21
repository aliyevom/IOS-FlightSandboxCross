from concurrent import futures
import grpc
import flight_scheduler_pb2
import flight_scheduler_pb2_grpc

class FlightSchedulerServicer(flight_scheduler_pb2_grpc.FlightSchedulerServicer):

    def ScheduleFlight(self, request, context):
        confirmation_message = f"Flight scheduled for pilot {request.pilot_id} on {request.flight_date}"
        return flight_scheduler_pb2.ScheduleFlightResponse(confirmation_message=confirmation_message)

def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    flight_scheduler_pb2_grpc.add_FlightSchedulerServicer_to_server(FlightSchedulerServicer(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    serve()
