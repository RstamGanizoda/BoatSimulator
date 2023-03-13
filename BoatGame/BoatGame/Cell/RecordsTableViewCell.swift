import UIKit

//MARK: - classes
class RecordsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var rowNumberLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - let/var
    static let identifier = "RecordsTableViewCell"
    
    // MARK: - functionality
    func configurePlayerName(name: String?) {
        self.playerNameLabel.text = name
    }
    
    func configurePlayerScore(score: Int) {
        self.playerScoreLabel.text = (String(describing: score))
    }
    
    func configureRowNumber(row: String) {
        self.rowNumberLabel.text = String(describing: row)
    }
    
    func configureDate(date: String?) {
        self.dateLabel.text = date
    }
}
