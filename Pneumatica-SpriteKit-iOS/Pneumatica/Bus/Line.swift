//
//  Line.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit
import DXPneumatic

class Line: SKShapeNode {
    var firstIO : GraphicalIO!
    var secondIO: GraphicalIO!
    
    func update() {
        if self.firstIO.modelIO.pressure > 0 && self.secondIO.modelIO.pressure > 0 {
            self.strokeColor = .green
        } else {
            self.strokeColor = .red
        }
    }
}
