import UIKit

//MARK: - extensions
private extension String {
    static let nameKey = "nameKey"
    static let boatImageKey = "boatImageKey"
    static let recordsKey = "recordsKey"
    static let enemyKey = "enemyKey"
}

//MARK: - classes
class StorageManager {
    
    //MARK: - let/var
    static let shared = StorageManager()
    private init() {}
    
    //MARK: - Functionality
    func saveEnemy(_ index: Int) {
        UserDefaults.standard.set(index, forKey: .enemyKey)
    }
    
    func loadEnemy() -> Int? {
        guard let name = UserDefaults.standard.object(forKey: .enemyKey) as? Int else { return nil}
        return name
    }
    
    func saveUserName(_ name: String) {
        UserDefaults.standard.set(name, forKey: .nameKey)
    }
    
    func loadUserName() -> String? {
        guard let name = UserDefaults.standard.object(forKey: .nameKey) as? String else { return nil}
        return name
    }
    
    func saveBoatName(_ name: String) {
        UserDefaults.standard.set(name, forKey: .boatImageKey)
    }
    
    func loadBoatName() -> String? {
        guard let name = UserDefaults.standard.object(forKey: .boatImageKey) as? String else { return nil}
        return name
    }
    
    func saveBoatImage(_ image: UIImage) -> String? {
        guard let directory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return nil }
        let fileName = UUID().uuidString
        let fileURL = directory.appendingPathComponent(fileName)
        guard let data = image.pngData() else { return nil }
        if  FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch let error {
                print(error)
                return nil
            }
        }
        do {
            try data.write(to: fileURL)
            return fileName
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func loadBoatImage(fileName : String) -> UIImage? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = directory.appendingPathComponent(fileName)
        let image = UIImage(contentsOfFile: fileURL.path)
        return image
    }
    
    func saveRecords(array: [Records]?) {
        UserDefaults.standard.set(encodable: array, forKey: .recordsKey)
    }
    
    func getRecords() -> [Records]? {
        guard let array = UserDefaults.standard.value([Records].self, forKey: .recordsKey) else {return nil}
        return array
    }
}

// MARK: - Extensions
extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }
    
    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(type, from: data){
            return value
        }
        return nil
    }
}
