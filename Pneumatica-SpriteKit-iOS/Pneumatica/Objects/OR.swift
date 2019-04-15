//
//  OR.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import Foundation

class ValvolaOR : ValvolaAnd {
    override var labelText: String {
        return "OR"
    }
    
    override func update() {
        if inputLeft.ariaPressure > 0 || inputRight.ariaPressure > 0 {
            mainOutput.ariaPressure = [inputLeft.ariaPressure, inputRight.ariaPressure].max() ?? 0.0
        } else {
            mainOutput.ariaPressure = 0.0
        }
    }
}
