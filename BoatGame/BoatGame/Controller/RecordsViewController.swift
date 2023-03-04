import UIKit

class RecordsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var recordsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainRecordsLabel: UILabel!
    
    // MARK: let/var
    var allRecords = StorageManager.shared.getRecords()
    let borderWidthForButtons = 0.5
    let rowAndHeaderHeight = CGFloat(55)
    let fontName = "DaysOne-Regular"
    let maxResultAmount = 15
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createBackground()
        createBackButton()
    }
    
    // MARK: Actions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: func
    private func createBackButton() {
        backButton.buttonParameters(borderWidth: self.borderWidthForButtons)
        backButton.dropShadow()
        backButton.setTitle("Back".localized, for: .normal)
    }
    
    private func createBackground() {
        backgroundView.addGradient()
        mainRecordsLabel.text = "Records".localized
    }
    
}

// MARK: extensions
extension RecordsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allRecords?.count ?? 0 <= maxResultAmount {
            return allRecords?.count ?? 0
        } else {
            return maxResultAmount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = recordsTableView.dequeueReusableCell(withIdentifier: RecordsTableViewCell.identifier, for: indexPath) as? RecordsTableViewCell,
              let sortedRecords = ( allRecords?.sorted { $0.score > $1.score} ) else { return UITableViewCell()}
        let allGameRecords = sortedRecords[indexPath.row]
        cell.configurePlayerName(name: allGameRecords.name)
        cell.configurePlayerScore(score: allGameRecords.score)
        cell.configureRowNumber(row: String(indexPath.row + 1))
        cell.configureDate(date: allGameRecords.date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowAndHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        cell.backgroundColor = UIColor(
            red: 1,
            green: 1,
            blue: 1,
            alpha: 0.3
        )
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: .zero)
        headerView.frame.size = CGSize(
            width: recordsTableView.frame.width,
            height: rowAndHeaderHeight
        )
        let label = UILabel()
        label.frame = CGRect(
            x: headerView.frame.origin.x,
            y: headerView.frame.origin.y,
            width: headerView.frame.width,
            height: headerView.frame.height
        )
        
        label.text = "Top fifteen results".localized
        let customFont = UIFont(name: fontName, size: UIFont.labelFontSize)
        label.font = UIFontMetrics.default.scaledFont(for: customFont ?? .systemFont(ofSize: 15))
        label.textColor = .black
        label.adjustsFontForContentSizeCategory = true
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        rowAndHeaderHeight
    }
}

