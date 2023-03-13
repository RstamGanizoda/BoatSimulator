import Foundation
import RxSwift
import RxCocoa

//MARK: - Classes
final class RecordViewControllerModel {
    
    //MARK: - let/var
    var allSavedRecords = StorageManager.shared.getRecords()
    let dataSource = BehaviorRelay<[Records]>(value: [])
    
    //MARK: - Functionality
    func createRecords() {
        if let sortedArray = (allSavedRecords?.sorted { $0.score > $1.score }){
            dataSource.accept(sortedArray)
        }
    }
}
