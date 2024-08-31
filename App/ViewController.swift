import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var flightDatePicker: UIDatePicker!
    @IBOutlet weak var pilotIDTextField: UITextField!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let apiGateway = ApiGateway.shared
    var flightSchedulerClient: FlightSchedulerClient?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        scheduleButton.layer.cornerRadius = 8
        statusLabel.text = ""
        activityIndicator.isHidden = true
    }

    @IBAction func authenticateTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            statusLabel.text = "Username and password cannot be empty."
            return
        }

        apiGateway.authenticateUser(username: username, password: password, role: .pilot) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    self?.flightSchedulerClient = FlightSchedulerClient(authToken: token)
                    self?.statusLabel.text = "Authentication successful. You can now schedule flights."
                case .failure(let error):
                    self?.statusLabel.text = "Authentication failed: \(error.localizedDescription)"
                }
            }
        }
    }

    @IBAction func scheduleFlightTapped(_ sender: UIButton) {
        guard let client = flightSchedulerClient else {
            statusLabel.text = "Please authenticate first."
            return
        }

        guard let pilotID = pilotIDTextField.text, !pilotID.isEmpty else {
            statusLabel.text = "Pilot ID cannot be empty."
            return
        }

        let flightDate = flightDatePicker.date
        statusLabel.text = ""
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        client.scheduleFlight(for: pilotID, on: flightDate) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true

                switch result {
                case .success(let confirmationMessage):
                    self?.statusLabel.text = "Flight scheduled: \(confirmationMessage)"
                case .failure(let error):
                    self?.statusLabel.text = "Failed to schedule flight: \(error.localizedDescription)"
                }
            }
        }
    }
}
