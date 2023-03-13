import UIKit

// MARK: - extensions
private extension CGPoint {
    static let gradientStartPoint = CGPoint(x: 0, y: 0)
    static let gradientEndPoint = CGPoint(x: 1, y: 1)
}

private extension String {
    static let gameViewControllerIdentifier = "GameViewController"
    static let settingsViewControllerIdentifier = "SettingsViewController"
    static let recordsViewControllerIdentifier = "RecordsViewController"
}

private extension UIImage {
    static let boatPreviewImage = UIImage(named: "boatPreview")
    static let boatForAnimation = UIImage(named: "boatForAnimation")
}

private extension CGFloat {
    static let defaultCornerRadius = CGFloat(10)
    static let cornerRadiusForButtons = CGFloat(16)
    static let shadowRadius = CGFloat(15)
}

private extension Double {
    static let durationForBoatAnimation = 1.1
    static let borderWidthForButtons = 0.5
    static let shadowOpacity = 0.5
    static let widthShadowOffset = 5.0
    static let heightShadowOffset = 8.0
}

// MARK: - enums
enum Direction {
    case down
    case right
    case up
    case left
}

// MARK: - classes
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
    var directionForBoatAnimation = Direction.left
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
    
    // MARK: - IBActions
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
        guard let controller = self.storyboard?
            .instantiateViewController(
                withIdentifier: .settingsViewControllerIdentifier) as? SettingsViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func moveToGameViewController() {
        if StorageManager.shared.loadUserName() == nil {
            self.showMissingSettingsAlert()
        } else{
            guard let controller = self.storyboard?
                .instantiateViewController(
                    withIdentifier: .gameViewControllerIdentifier) as? GameViewController else {
                return
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func moveToRecordsViewController() {
        guard let controller = self.storyboard?
            .instantiateViewController(
                withIdentifier: .recordsViewControllerIdentifier) as? RecordsViewController else {
            return
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - UI
    private func addAllButtons(){
        createGameButton()
        createRecordsButton()
        createSettingsButton()
    }
    
    private func createBoatPreview(){
        self.boatPreviewImageView.image = .boatPreviewImage
    }
    
    private func createBoatForAnimation(){
        self.boatAnimationImageView.image = .boatForAnimation
    }
    
    private func createGameButton() {
        startGameButton.dropShadow()
        startGameButton.buttonParameters(
            radius: .cornerRadiusForButtons,
            backgroundColor: self.colorForStartButton,
            borderWidth: .borderWidthForButtons
        )
        startGameButton.setTitle("Start Game".localized, for: .normal)
    }
    
    private func createSettingsButton() {
        settingsButton.buttonParameters(borderWidth: .borderWidthForButtons)
        settingsButton.dropShadow()
        settingsButton.setTitle("Settings".localized, for: .normal)
        
    }
    
    private func createRecordsButton() {
        recordsButton.buttonParameters(borderWidth: .borderWidthForButtons)
        recordsButton.dropShadow()
        recordsButton.setTitle("Records".localized, for: .normal)
    }
    
    private func createBackground() {
        backgroundView.addGradient()
        gameNameLabel.text = "Boat Simulator".localized
    }
    
    // MARK: - Functionality
    private func moveBoat() {
        UIView.animate(withDuration: .durationForBoatAnimation) {
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
        createAlert(
            title: "Missing game settings".localized,
            message: "Please, set the game parameters".localized,
            options: "Cancel".localized,
            "Set".localized
        ) { (option) in
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
    func buttonParameters(
        radius: CGFloat = .defaultCornerRadius,
        backgroundColor: UIColor = .systemGray,
        borderWidth: Double
    ) {
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
    }
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = Float(.shadowOpacity)
        self.layer.shadowOffset = CGSize(
            width: .widthShadowOffset,
            height: .heightShadowOffset
        )
        self.layer.shadowRadius = .shadowRadius
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath
    }
    
    func addGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.cgColor,
                           UIColor.yellow.cgColor]
        gradient.startPoint = .gradientStartPoint
        gradient.endPoint = .gradientEndPoint
        gradient.frame = self.bounds
        self.layer.addSublayer(gradient)
    }
}

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
