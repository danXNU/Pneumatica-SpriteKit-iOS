//
//  Line.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class Line: SKShapeNode {
    var firstIO : InputOutput!
    var secondIO: InputOutput!
    
    func update() {
        if self.firstIO.ariaPressure > 0 && self.secondIO.ariaPressure > 0 {
            self.strokeColor = .green
        } else {
            self.strokeColor = .red
        }
    }
}
