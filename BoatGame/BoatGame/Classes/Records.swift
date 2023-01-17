import Foundation

class Records: Codable {
    
    let name: String?
    let score: Int
    let date: String?
    
    init(name: String?, score: Int, date: String?) {
        self.name = name
        self.score = score
        self.date = date
    }
}

