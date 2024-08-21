import UIKit

class ViewController: UIViewController {

    // UI Elements
    @IBOutlet weak var flightDatePicker: UIDatePicker!
    @IBOutlet weak var pilotIDTextField: UITextField!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    let flightScheduler = FlightScheduler()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed
        setupUI()
    }

    private func setupUI() {
        // Customize UI elements
        scheduleButton.layer.cornerRadius = 8
        statusLabel.text = ""
    }

    @IBAction func scheduleFlightTapped(_ sender: UIButton) {
        guard let pilotID = pilotIDTextField.text, !pilotID.isEmpty else {
            statusLabel.text = "Pilot ID cannot be empty."
            return
        }

        let flightDate = flightDatePicker.date

        // Schedule the flight
        flightScheduler.scheduleFlight(for: pilotID, on: flightDate) { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.statusLabel.text = "Flight scheduled: \(response)"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.statusLabel.text = "Failed to schedule flight: \(error.localizedDescription)"
                }
            }
        }
    }
}
