import UIKit

// MARK: enums
enum Direction {
    case down
    case right
    case up
    case left
}

class MainMenuViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var boatPreviewImageView: UIImageView!
    @IBOutlet weak var boatAnimationImageView: UIImageView!
    @IBOutlet weak var boatAnimationView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var recordsButton: UIButton!
    @IBOutlet weak var gameNameLabel: UILabel!
    
    // MARK: - let/var
    let viewControllerIdentifier = "ViewController"
    let SettingsViewControllerIdentifier = "SettingsViewController"
    let RecordsViewControllerIdentifier = "RecordsViewController"
    var directionForBoatAnimation = Direction.left
    let durationForBoatAnimation = 1.1
    let borderWidthForButtons = 0.5
    let cornerRadiusForButtons = CGFloat(16)
    let colorForStartButton: UIColor = .systemBlue
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createBoatForAnimation()
        moveBoat()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addAllButtons()
        createBackground()
        createBoatPreview()
    }
    
    // MARK: - Actions
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        moveToGameViewController()
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        moveToSettingsViewController()
    }
    
    @IBAction func recordsButtonPressed(_ sender: UIButton) {
        moveToRecordsViewController()
    }
    
    // MARK: - Navigation
    private func moveToSettingsViewController(){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: self.SettingsViewControllerIdentifier) as? SettingsViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func moveToGameViewController() {
        if StorageManager.shared.loadUserName() == nil {
            self.showMissingSettingsAlert()
        } else{
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: self.viewControllerIdentifier) as? ViewController else {
                return
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    private func moveToRecordsViewController() {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: self.RecordsViewControllerIdentifier) as? RecordsViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: func
    private func addAllButtons(){
        createGameButton()
        createRecordsButton()
        createSettingsButton()
    }
    
    private func createBoatPreview(){
        let boatPreviewImage = UIImage(named: "boatPreview")
        self.boatPreviewImageView.image = boatPreviewImage
    }
    
    private func createBoatForAnimation(){
        let boatForAnimation = UIImage(named: "boatForAnimation")
        self.boatAnimationImageView.image = boatForAnimation
    }
    
    private func createGameButton() {
        startGameButton.dropShadow()
        startGameButton.buttonParameters(
            radius: self.cornerRadiusForButtons,
            backgroundColor: self.colorForStartButton,
            borderWidth: self.borderWidthForButtons
        )
        startGameButton.setTitle("Start Game".localized, for: .normal)
    }
    
    private func createSettingsButton() {
        settingsButton.buttonParameters(borderWidth: self.borderWidthForButtons)
        settingsButton.dropShadow()
        settingsButton.setTitle("Settings".localized, for: .normal)
        
    }
    
    private func createRecordsButton() {
        recordsButton.buttonParameters(borderWidth: self.borderWidthForButtons)
        recordsButton.dropShadow()
        recordsButton.setTitle("Records".localized, for: .normal)
    }
    
    private func createBackground() {
        backgroundView.addGradient()
        gameNameLabel.text = "Boat Simulator".localized
    }
    
    private func moveBoat() {
        UIView.animate(withDuration: self.durationForBoatAnimation) {
            self.changeDirectionOfTheImage()
        } completion: { _ in
            self.moveBoat()
        }
    }
    
    private func changeDirectionOfTheImage(){
        switch directionForBoatAnimation {
        case .down:
            boatAnimationImageView.frame.origin.y += self.boatAnimationView.frame.height - self.boatAnimationImageView.frame.height
            directionForBoatAnimation = .right
        case .right:
            boatAnimationImageView.frame.origin.x += self.boatAnimationView.frame.width - self.boatAnimationImageView.frame.width
            directionForBoatAnimation = .up
        case .up:
            boatAnimationImageView.frame.origin.y -= self.boatAnimationView.frame.height - self.boatAnimationImageView.frame.height
            directionForBoatAnimation = .left
        case .left:
            boatAnimationImageView.frame.origin.x -= self.boatAnimationView.frame.width - self.boatAnimationImageView.frame.width
            directionForBoatAnimation = .down
        }
    }
    
    private func showMissingSettingsAlert(){
        createAlert(title: "Missing game settings".localized, message: "Please, set the game parameters".localized, options: "Cancel".localized, "Set".localized) { (option) in
            switch (option) {
            case "Cancel".localized:
                break
            case "Set".localized:
                self.moveToSettingsViewController()
                break
            default:
                break
            }
        }
    }
}

// MARK: - EXTENSIONS
extension UIView {

    func buttonParameters(radius: CGFloat = 10, backgroundColor: UIColor = .systemGray, borderWidth: Double) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
    }

    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 5, height: 8)
        self.layer.shadowRadius = 15
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }

    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.cgColor,
                           UIColor.yellow.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = self.bounds
        self.layer.addSublayer(gradient)
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}


