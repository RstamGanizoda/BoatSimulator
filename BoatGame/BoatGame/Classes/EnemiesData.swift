import Foundation

//MARK: classes
final class EnemiesData {
    
    //MARK: let/var
    static let shared = EnemiesData()
    var enemies: [Enemies]
    
    private init() {
        enemies = [
            Enemies(
                firstEnemy: "firstMountain",
                secondEnemy: "secondMountain",
                thirdEnemy: "thirdMountain"
            ),
            Enemies(
                firstEnemy: "firstIceberg",
                secondEnemy: "secondIceberg",
                thirdEnemy: "thirdIceberg"
            ),
            Enemies(
                firstEnemy: "firstWhale",
                secondEnemy: "secondWhale",
                thirdEnemy: "thirdWhale"
            ),
        ]
    }
}

//MARK: classes
final class Enemies {
    
    //MARK: let/var
    var firstEnemy: String
    var secondEnemy: String
    var thirdEnemy: String
    
    init(firstEnemy: String, secondEnemy: String, thirdEnemy: String) {
        self.firstEnemy = firstEnemy
        self.secondEnemy = secondEnemy
        self.thirdEnemy = thirdEnemy
    }
}
