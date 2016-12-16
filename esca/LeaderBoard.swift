//
//  LeaderBoard.swift
//  esca
//
//  Created by Brandon Vo on 12/16/16.
//
//

import Foundation

class LeaderBoard {
    var name:String?
    var score:Int?

    
    init(name:String, score:Int) {
        self.score = score
        self.name = name
    }
}
