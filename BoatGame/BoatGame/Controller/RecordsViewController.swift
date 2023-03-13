import UIKit
import RxCocoa
import RxSwift

//MARK: - Extensions
private extension String {
    static let fontName = "DaysOne-Regular"
}

private extension CGFloat {
    static let borderWidthForButtons = 0.5
    static let rowAndHeaderHeight = CGFloat(55)
    static let defaultFontSize = CGFloat(15)
}

private extension UIColor {
    static let recordTableBackgroundColor = UIColor(
        red: 1,
        green: 1,
        blue: 1,
        alpha: 0.3
    )
}

//MARK: - Classes
class RecordsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var recordsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainRecordsLabel: UILabel!
    
    // MARK: - let/var
    let viewModel = RecordViewControllerModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.createRecords()
        configureRecordTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createBackground()
        createBackButton()
    }
    
    // MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UI
    private func createBackButton() {
        backButton.buttonParameters(borderWidth: Double(.borderWidthForButtons))
        backButton.dropShadow()
        backButton.setTitle("Back".localized, for: .normal)
    }
    
    private func createBackground() {
        backgroundView.addGradient()
        mainRecordsLabel.text = "Records".localized
    }
    
    // MARK: - Functionality
    private func configureRecordTable() {
        viewModel.dataSource.bind(
            to: recordsTableView.rx.items(
                cellIdentifier: RecordsTableViewCell.identifier,
                cellType: RecordsTableViewCell.self)) { index, model, cell in
                    cell.configurePlayerName(name: model.name)
                    cell.configureDate(date: model.date)
                    cell.configureRowNumber(row: String(index + 1))
                    cell.configurePlayerScore(score: model.score)
                }.disposed(by: disposeBag)
        recordsTableView.delegate = self
    }
}

// MARK: - Extensions
extension RecordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        .rowAndHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        cell.backgroundColor = .recordTableBackgroundColor
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: .zero)
        headerView.frame.size = CGSize(
            width: recordsTableView.frame.width,
            height: .rowAndHeaderHeight
        )
        let label = UILabel()
        label.frame = CGRect(
            x: headerView.frame.origin.x,
            y: headerView.frame.origin.y,
            width: headerView.frame.width,
            height: headerView.frame.height
        )
        
        label.text = "Top results".localized
        let customFont = UIFont(
            name: .fontName,
            size: UIFont.labelFontSize
        )
        label.font = UIFontMetrics.default.scaledFont(for: customFont ?? .systemFont(ofSize: .defaultFontSize))
        label.textColor = .black
        label.adjustsFontForContentSizeCategory = true
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .rowAndHeaderHeight
    }
}
