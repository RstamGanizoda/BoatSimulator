import UIKit

//MARK: - Extensions
private extension Double {
    static let borderWidthForButtons = 0.5
}

private extension CGFloat {
    static let cornerRadiusForButtons = CGFloat(16)
}

//MARK: - Classes
class SettingsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var boatSegmentedControl: UISegmentedControl!
    @IBOutlet weak var enemySegmentControl: UISegmentedControl!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var selectTheBoatLabel: UILabel!
    @IBOutlet weak var selectTheEnemyLabel: UILabel!
    @IBOutlet weak var enterPlayerNameLabel: UILabel!
    @IBOutlet weak var mainGameSettingsLabel: UILabel!
    
    // MARK: - let/var
    let colorForSaveButtons: UIColor = .systemBlue
    let storageManager = StorageManager.shared
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapRecognizerForClosingKeyboard()
        loadNameInNameTextField()
        saveChosenSegmentedOption()
        createSegmentedControl()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addAllLabels()
        createBackground()
        createCloseButton()
        createSaveButton()
    }
    
    // MARK: - IBActions
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.closeSettingsMenu()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.boatSegmentedSelected(boatSegmentedControl)
        self.enemySegmentedSelected(enemySegmentControl)
        self.saveUserName()
    }
    
    @IBAction func boatSegmentedSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.chooseBoat(boatName: "boat")
        case 1:
            self.chooseBoat(boatName: "purpleBoat")
        case 2:
            self.chooseBoat(boatName: "greenBoat")
        default:
            self.chooseBoat(boatName: "boat")
        }
        UserDefaults.standard.set(
            sender.selectedSegmentIndex,
            forKey: "chosenOptionOfBoats"
        )
    }
    
    @IBAction func enemySegmentedSelected(_ sender: UISegmentedControl) {
        storageManager.saveEnemy(sender.selectedSegmentIndex)
        UserDefaults.standard.set(
            sender.selectedSegmentIndex,
            forKey: "chosenOptionOfEnemy"
        )
    }
    
    // MARK: - Navigation
    private func closeSettingsMenu() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI
    private func createBackground() {
        backgroundView.addGradient()
    }
    
    private func addAllLabels(){
        mainGameSettingsLabel.text = "Game Settings".localized
        enterPlayerNameLabel.text = "Enter the player name".localized
        nameTextField.placeholder = "Please enter your name".localized
        selectTheBoatLabel.text = "Select the boat".localized
        selectTheEnemyLabel.text = "Select the enemy".localized
    }
    
    private func createCloseButton() {
        closeButton.buttonParameters(borderWidth: .borderWidthForButtons)
        closeButton.dropShadow()
        closeButton.setTitle("Back".localized, for: .normal)
    }
    
    private func createSaveButton() {
        saveButton.dropShadow()
        saveButton.buttonParameters(
            radius: .cornerRadiusForButtons,
            backgroundColor: self.colorForSaveButtons,
            borderWidth: .borderWidthForButtons
        )
        saveButton.setTitle("Save".localized, for: .normal)
    }
    
    private func addTapRecognizerForClosingKeyboard(){
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapDetected(_:))
        )
        recognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(recognizer)
    }
    
    @objc func tapDetected(_ recognizer: UITapGestureRecognizer) {
        self.nameTextField.resignFirstResponder()
    }
    
    // MARK: - Functionality
    private func createSegmentedControl() {
        boatSegmentedControl.setTitle("White".localized, forSegmentAt: 0)
        boatSegmentedControl.setTitle("Purple".localized, forSegmentAt: 1)
        boatSegmentedControl.setTitle("Green".localized, forSegmentAt: 2)
        enemySegmentControl.setTitle("Mountains".localized, forSegmentAt: 0)
        enemySegmentControl.setTitle("Icebergs".localized, forSegmentAt: 1)
        enemySegmentControl.setTitle("Whales".localized, forSegmentAt: 2)
    }
    
    private func chooseBoat(boatName: String) {
        guard let image = UIImage(named: boatName),
              let imageName = storageManager.saveBoatImage(image) else {
            return }
        storageManager.saveBoatName(imageName)
    }
    
    private func saveUserName(){
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
            if self.nameTextField.text == "" {
                self.missingPlayerNameAlert()
            } else {
                guard let playerName = self.nameTextField.text else { return }
                self.storageManager.saveUserName(playerName)
                self.closeSettingsMenu()
            }
        }
    }
    
    private func saveChosenSegmentedOption (){
        if let firstValue = UserDefaults.standard.value(forKey: "chosenOptionOfBoats") {
            guard let selectedIndex = firstValue as? Int else { return }
            boatSegmentedControl.selectedSegmentIndex = selectedIndex
        }
        if let secondValue = UserDefaults.standard.value(forKey: "chosenOptionOfEnemy") {
            guard let selectedIndex = secondValue as? Int else { return }
            enemySegmentControl.selectedSegmentIndex = selectedIndex
        }
    }
    
    private func missingPlayerNameAlert(){
        let alert = UIAlertController(
            title: "Error".localized,
            message: "Please, write the player name".localized,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        )
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    private func loadNameInNameTextField() {
        let text = storageManager.loadUserName()
        self.nameTextField.text = text
    }
}

// MARK: - Extensions
extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
