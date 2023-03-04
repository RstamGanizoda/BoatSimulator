//
//  RecordViewModel.swift
//  BoatGame
//
//  Created by Rstam Ganizoda on 10/02/2023.
//

import Foundation
import RxSwift
import RxCocoa

final class RecordViewModel {
    
    var allSavedRecords = StorageManager.shared.getRecords()
    let dataSource = BehaviorRelay<[Records]>(value: [])
    
    func createRecords() {
        if let sortedArray = (allSavedRecords?.sorted { $0.score > $1.score }){
            dataSource.accept(sortedArray)
        }
    }
    
}
