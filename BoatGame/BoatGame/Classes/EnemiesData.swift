import Foundation

class EnemiesData {
    
    static let shared = EnemiesData()
    var enemies: [Enemies]
    
    private init() {
        enemies = [
            Enemies(firstEnemy: "firstMountain", secondEnemy: "secondMountain", thirdEnemy: "thirdMountain"),
            Enemies(firstEnemy: "firstIceberg", secondEnemy: "secondIceberg", thirdEnemy: "thirdIceberg"),
            Enemies(firstEnemy: "firstWhale", secondEnemy: "secondWhale", thirdEnemy: "thirdWhale"),
        ]
    }
}
