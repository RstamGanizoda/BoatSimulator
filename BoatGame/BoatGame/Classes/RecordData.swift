import Foundation

class RecordData: Codable {

    static let shared = RecordData()
    var recordsArray : [Records]?
    
    init() {
        recordsArray = []
    }
}
