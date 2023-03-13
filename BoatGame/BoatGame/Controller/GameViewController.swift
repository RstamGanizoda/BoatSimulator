import UIKit
import AVFoundation
import CoreMotion

//MARK: - Extensions
private extension Double {
    static let durationForBoat = 0.3
    static let durationForBoatJump = 1.0
    static let borderWidthForButtons = 0.5
    static let durationForTheSea = 10.1
    static let durationForFirstEnemy = 8.1
    static let durationForSecondEnemy = 7.1
    static let durationForThirdEnemy = 6.1
    static let shadowOpacity = 0.5
    static let widthShadowOffset = 5.0
    static let heightShadowOffset = 8.0
}

private extension Int {
    static let widthOfEnemies = 60
    static let heightOfEnemies = 60
}

private extension CGFloat {
    static let directionForBoat = CGFloat(10)
    static let cornerRadiusForButtons = CGFloat(16)
    static let downDirection = CGFloat(300)
    static let boatSize = CGFloat(80)
    static let shadowRadius = CGFloat(15)
}

private extension String {
    static let gameSoundtrack = "gameSoundtrack"
    static let boatExplosionSound = "boatExplosion"
    static let dateFormat = "HH:mm:ss, MMM d, yyyy"
}

//MARK: - classes
class GameViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    //  MARK: - let/var
    var recordArray = RecordData.shared.recordsArray
    let getSavedRecords = StorageManager.shared.getRecords()
    let chosenEnemyIndex = StorageManager.shared.loadEnemy()
    let enemiesArray = EnemiesData.shared.enemies
    let motionManager = CMMotionManager()
    let dateFormatter = DateFormatter()
    let date = Date()
    var scoreTimer = Timer()
    var intersectionTimer = Timer()
    var player: AVAudioPlayer?
    private let aboveSeaImageView = UIImageView()
    private let seaImageView = UIImageView()
    private var enemies: [UIImageView] = []
    private let boatImageView = UIImageView()
    private let firstEnemyImageView = UIImageView()
    private let secondEnemyImageView = UIImageView()
    private let thirdEnemyImageView = UIImageView()
    private let colorForDirectionButtons: UIColor = .systemBlue
    private var scores = 0
    private var accelerometerUpdateInterval = 0.10
    private var gyroUpdateInterval = 0.50
    private var seaImage = UIImage(named: "backgroundsWaves")
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPreviousRecords()
        playAudio(song: .gameSoundtrack, numberOfLoops: -1)
        setupIntersectionTimer()
        setupScoreTimer()
        addUserName()
        createBackground()
        moveSeaDown()
        addAccelerometer()
        makeBoatJumpGyro()
        addTapRecognizerForBoatJump()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createBackButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createBoat()
        createAllEnemies()
    }
    
    // MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: UIButton){
        intersectionTimer.invalidate()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        self.popToMainMenuVC()
        player?.stop()
    }
    
    // MARK: - Navigation
    private func popToMainMenuVC(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - UI
    private  func addUserName() {
        if let playerName = StorageManager.shared.loadUserName() {
            self.topLabel.text = ("Good luck, ".localized + "\(playerName)")
        }
    }
    
    private func createBackground(){
        self.seaImageView.frame = CGRect(
            x: self.backgroundView.frame.origin.x,
            y: self.backgroundView.frame.origin.y,
            width: self.backgroundView.frame.width,
            height: self.backgroundView.frame.height
        )
        self.seaImageView.image = self.seaImage
        self.seaImageView.contentMode = .scaleAspectFill
        self.backgroundView.addSubview(seaImageView)
        
        self.aboveSeaImageView.frame.origin = CGPoint(
            x: self.backgroundView.frame.origin.x,
            y: -self.backgroundView.frame.height
        )
        self.aboveSeaImageView.frame.size = self.seaImageView.frame.size
        self.aboveSeaImageView.image = self.seaImage
        self.aboveSeaImageView.contentMode = .scaleAspectFill
        self.backgroundView.addSubview(aboveSeaImageView)
    }
    
    private func moveSeaDown () {
        UIView.animate(
            withDuration: .durationForTheSea,
            delay: 0,
            options: .curveLinear
        ) {
            self.seaImageView.frame.origin.y = self.backgroundView.frame.height
            self.aboveSeaImageView.frame.origin.y = self.backgroundView.frame.origin.y
        } completion: { _ in
            self.putImagesBack()
        }
    }
    
    private func putImagesBack() {
        self.seaImageView.frame.origin.y = self.backgroundView.frame.origin.y
        self.aboveSeaImageView.frame.origin.y = -self.backgroundView.frame.height
        self.moveSeaDown()
    }
    
    private  func createBoat(){
        boatImageView.frame = CGRect(
            x: self.gameView.frame.width / 2 - .boatSize / 2,
            y: self.gameView.frame.height - .boatSize * 1.5,
            width: .boatSize,
            height: .boatSize
        )
        guard let imageName = StorageManager.shared.loadBoatName() else { return }
        let boatImage = StorageManager.shared.loadBoatImage(fileName: imageName)
        self.boatImageView.image = boatImage
        boatImageView.dropShadowForImages()
        self.gameView.addSubview(boatImageView)
    }
    
    private  func createBackButton(){
        backButton.dropShadow()
        backButton.buttonParameters(borderWidth: .borderWidthForButtons)
        backButton.setTitle("Back".localized, for: .normal)
    }
    
    private func createExplosion() {
        let explosionImage = UIImage(named: "explosion")
        self.boatImageView.image = explosionImage
    }
    
    // MARK: - Functionality
    private func addTapRecognizerForBoatJump(){
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapDetected(_:))
        )
        recognizer.numberOfTapsRequired = 2
        self.gameView.addGestureRecognizer(recognizer)
    }
    
    @objc func tapDetected(_ recognizer: UITapGestureRecognizer) {
        self.addBoatJumpAnimation()
    }
    
    private func makeBoatJumpGyro() {
        motionManager.gyroUpdateInterval = self.gyroUpdateInterval
        motionManager.startGyroUpdates(to: .main) { data, error in
            guard let info = data?.rotationRate else { return }
            let shake = info.x
            if shake >= 1.20 || shake <= -1.20 {
                self.addBoatJumpAnimation()
            }
        }
    }
    
    private func addBoatJumpAnimation(){
        self.intersectionTimer.invalidate()
        UIView.animate(withDuration: .durationForBoatJump) {
            self.boatImageView.frame.size = CGSize(
                width: .boatSize * 2,
                height: .boatSize * 2
            )
            self.boatImageView.frame.origin.y = self.gameView.frame.height - .boatSize * 4
        } completion: { _ in
            UIView.animate(withDuration: .durationForBoatJump) {
                self.boatImageView.frame.size = CGSize(
                    width: .boatSize,
                    height: .boatSize
                )
                self.boatImageView.frame.origin.y = self.gameView.frame.height - .boatSize * 1.5
            } completion: { _ in
                self.setupIntersectionTimer()
            }
        }
    }
    
    private func addAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let info = data?.acceleration else { return }
            let slope = info.x
            if slope > 0.15 && slope < 0.35 {
                self.motionManager.accelerometerUpdateInterval = self.accelerometerUpdateInterval
                self.moveBoatRight()
            }
            if slope >= 0.35 {
                self.motionManager.accelerometerUpdateInterval = self.accelerometerUpdateInterval / 2
                self.moveBoatRight()
            }
            if slope < -0.15 && slope > -0.35 {
                self.motionManager.accelerometerUpdateInterval = self.accelerometerUpdateInterval
                self.moveBoatLeft()
            }
            if slope <= -0.35 {
                self.motionManager.accelerometerUpdateInterval = self.accelerometerUpdateInterval / 2
                self.moveBoatLeft()
            }
        }
    }
    
    private func moveBoatRight() {
        if self.boatImageView.frame.origin.x <= self.view.frame.width - self.boatImageView.frame.width {
            UIView.animate(withDuration: .durationForBoat) {
                self.boatImageView.frame.origin.x += .directionForBoat }
        } else {
            gameOver()
        }
    }
    
    private func moveBoatLeft() {
        if self.boatImageView.frame.origin.x >= 0 {
            UIView.animate(withDuration: .durationForBoat) {
                self.boatImageView.frame.origin.x -= .directionForBoat }
        } else {
            gameOver()
        }
    }
    
    private func createAllEnemies(){
        createEnemy(
            enemyImageView: firstEnemyImageView,
            mountainEnemy: enemiesArray[0].firstEnemy,
            icebergEnemy: enemiesArray[1].firstEnemy,
            whaleEnemy: enemiesArray[2].firstEnemy,
            enemyDuration: .durationForFirstEnemy
        )
        createEnemy(
            enemyImageView: secondEnemyImageView,
            mountainEnemy: enemiesArray[0].secondEnemy,
            icebergEnemy: enemiesArray[1].secondEnemy,
            whaleEnemy: enemiesArray[2].secondEnemy,
            enemyDuration: .durationForSecondEnemy
        )
        createEnemy(
            enemyImageView: thirdEnemyImageView,
            mountainEnemy: enemiesArray[0].thirdEnemy,
            icebergEnemy: enemiesArray[1].thirdEnemy,
            whaleEnemy: enemiesArray[2].thirdEnemy,
            enemyDuration: .durationForThirdEnemy
        )
    }
    
    private func createEnemy(
        enemyImageView: UIImageView,
        mountainEnemy: String,
        icebergEnemy: String,
        whaleEnemy: String,
        enemyDuration: Double
    ){
        let x = Int(arc4random_uniform(UInt32(gameView.frame.width)))
        let y = Int(arc4random_uniform(UInt32(gameView.frame.origin.x)))
        let coordinatesForEnemies = CGRect(
            x: x,
            y: y,
            width: .widthOfEnemies,
            height: .heightOfEnemies
        )
        switch chosenEnemyIndex {
        case 0:
            if let firstEnemy = UIImage(named: mountainEnemy) {
                enemyImageView.image = firstEnemy
            }
        case 1:
            if let firstEnemy = UIImage(named: icebergEnemy) {
                enemyImageView.image = firstEnemy
            }
        case 2:
            if let firstEnemy = UIImage(named: whaleEnemy) {
                enemyImageView.image = firstEnemy
            }
        case .some(_):
            print("some")
            
        case .none:
            print("none")
        }
        enemyImageView.frame = coordinatesForEnemies
        self.enemies.append(enemyImageView)
        self.gameView.addSubview(enemyImageView)
        self.gameView.sendSubviewToBack(enemyImageView)
        UIView.animate(withDuration: enemyDuration, delay: 0, options: .curveLinear) {
            enemyImageView.frame.origin.y += self.view.frame.height + self.gameView.frame.height
        } completion: { _ in
            enemyImageView.removeFromSuperview()
            self.enemies.removeFirst()
            self.createEnemy(
                enemyImageView: enemyImageView,
                mountainEnemy: mountainEnemy,
                icebergEnemy: icebergEnemy,
                whaleEnemy: whaleEnemy,
                enemyDuration: enemyDuration
            )
        }
        enemyImageView.dropShadowForImages()
    }
    
    private func checkPlayerIntersection() {
        guard let boatLayer = boatImageView.layer.presentation() else { return }
        for element in self.enemies {
            guard let allEnemies = element.layer.presentation() else { return }
            if !(boatLayer.isEqual(allEnemies)) {
                if boatLayer.frame.intersects(allEnemies.frame){
                    self.gameOver()
                }
            }
        }
    }
    
    private func setupIntersectionTimer() {
        self.intersectionTimer = Timer(
            timeInterval: 1 / 60,
            target: self,
            selector: #selector(fireTimer),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(intersectionTimer, forMode: .common)
        intersectionTimer.fire()
    }
    
    @objc func fireTimer(){
        self.checkPlayerIntersection()
    }
    
    private func setupScoreTimer() {
        self.scoreTimer = Timer(
            timeInterval: 1 / 10,
            target: self,
            selector: #selector(fireScoreTimer),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(scoreTimer, forMode: .common)
        scoreTimer.fire()
    }
    
    @objc func fireScoreTimer(){
        scores += 1
        self.scoreLabel.text = "\(scores)"
        
    }
    
    private func loadPreviousRecords() {
        if ((getSavedRecords?.isEmpty) != nil) {
            recordArray = getSavedRecords
        }
    }
    
    private func playAudio(song: String, numberOfLoops: Int) {
        guard let fileName = Bundle.main.path(forResource: song, ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: fileName)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        try? player = AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
        player?.numberOfLoops = numberOfLoops
    }
    
    private func gameOverAlert(){
        createAlert(
            title: "GAME OVER".localized,
            message: ("Your score is ".localized + "\(scores)"),
            options: "Try again".localized
        ) { (option) in
            switch (option) {
            case "Try again".localized:
                self.popToMainMenuVC()
                break
            default:
                break
            }
        }
    }
    
    private func gameOver(){
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        scoreTimer.invalidate()
        intersectionTimer.invalidate()
        createExplosion()
        gameOverAlert()
        self.thirdEnemyImageView.removeFromSuperview()
        self.firstEnemyImageView.removeFromSuperview()
        self.secondEnemyImageView.removeFromSuperview()
        player?.stop()
        playAudio(song: .boatExplosionSound, numberOfLoops: 0)
        dateFormatter.dateFormat = .dateFormat
        let currentDate = dateFormatter.string(from: date)
        let result = Records(
            name: StorageManager.shared.loadUserName(),
            score: scores,
            date: currentDate
        )
        recordArray?.append(result)
        StorageManager.shared.saveRecords(array: recordArray)
    }
}

// MARK: - Extensions
extension UIImageView {
    func dropShadowForImages() {
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
}
