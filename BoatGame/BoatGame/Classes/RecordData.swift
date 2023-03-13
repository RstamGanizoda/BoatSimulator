import Foundation

//MARK: - classes
final class RecordData: Codable {
    
    //MARK: - let/var
    static let shared = RecordData()
    var recordsArray : [Records]?
    
    init() {
        recordsArray = []
    }
}

//MARK: - classes
final class Records: Codable {
    
    //MARK: - let/var
    let name: String?
    let score: Int
    let date: String?
    
    init(name: String?, score: Int, date: String?) {
        self.name = name
        self.score = score
        self.date = date
    }
}
