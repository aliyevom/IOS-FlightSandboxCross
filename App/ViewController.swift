import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var airlineSegmentControl: UISegmentedControl!
    @IBOutlet weak var flightNumberTextField: UITextField!
    @IBOutlet weak var fetchDetailsButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let airlineAPIManager = AirlineAPIManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        fetchDetailsButton.layer.cornerRadius = 8
        statusLabel.text = ""
        activityIndicator.isHidden = true
    }

    @IBAction func fetchFlightDetailsTapped(_ sender: UIButton) {
        guard let flightNumber = flightNumberTextField.text, !flightNumber.isEmpty else {
            statusLabel.text = "Flight number cannot be empty."
            return
        }

        let selectedAirline: Airline
        switch airlineSegmentControl.selectedSegmentIndex {
        case 0:
            selectedAirline = .thy
        case 1:
            selectedAirline = .flydubai
        case 2:
            selectedAirline = .pegasus
        case 3:
            selectedAirline = .wizzair
        default:
            statusLabel.text = "Please select an airline."
            return
        }

        statusLabel.text = ""
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        airlineAPIManager.fetchFlightDetails(for: selectedAirline, flightNumber: flightNumber) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true

                switch result {
                case .success(let flightDetails):
                    self?.statusLabel.text = "Flight details: \(flightDetails)"
                case .failure(let error):
                    self?.statusLabel.text = "Failed to fetch flight details: \(error.localizedDescription)"
                }
            }
        }
    }
}
