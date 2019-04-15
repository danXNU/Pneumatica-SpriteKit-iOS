//
//  Line.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class Line: SKShapeNode {
    var fromInput : InputOutput!
    var toOutput: InputOutput!
    
    func update() {
        if self.fromInput.ariaPressure > 0 && self.toOutput.ariaPressure > 0 {
            self.strokeColor = .green
        } else {
            self.strokeColor = .red
        }
    }
}
