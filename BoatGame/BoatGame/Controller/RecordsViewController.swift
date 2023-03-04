import UIKit
import RxCocoa
import RxSwift

class RecordsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var recordsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainRecordsLabel: UILabel!
    
    // MARK: let/var
    let viewModel = RecordViewModel()
    private let disposeBag = DisposeBag()
    let borderWidthForButtons = 0.5
    let rowAndHeaderHeight = CGFloat(55)
    let fontName = "DaysOne-Regular"
    
    // MARK: lifecycle
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

// MARK: extensions
extension RecordsViewController: UITableViewDelegate {
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

        label.text = "Top results".localized
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

