//
//  Objects.swift
//  Pneumatica
//
//  Created by Dani Tox on 02/04/2019.
//

import SpriteKit
import UIKit

class ValvolaAnd : SKShapeNode, ValvolaConformance {
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "AND"
    }
    
    var inputLeft : InputOutput!
    var inputRight: InputOutput!
    var mainOutput: InputOutput!
    
//    var ios: [InputOutput] {
//        return [inputLeft, inputRight, mainOutput]
//    }
    
    required init(size: CGSize) {
        super.init()
        self.fillColor = .clear
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        enable()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enable() {
        
        self.inputLeft  = InputOutput(circleOfRadius: 10, valvola: self)
        self.inputRight = InputOutput(circleOfRadius: 10, valvola: self)
        self.mainOutput = InputOutput(circleOfRadius: 10, valvola: self)
        
        inputLeft.idNumber = 0
        inputRight.idNumber = 1
        mainOutput.idNumber = 2
        
        let w = self.frame.size.width
        inputLeft.position.x = 0 - (inputLeft.frame.width / 2)
        inputLeft.position.y = 0 - (inputLeft.frame.height / 2)
        inputLeft.zPosition = self.zPosition + 1
        
        inputRight.position.x = w - (inputLeft.frame.width / 2)
        inputRight.position.y = 0 - (inputLeft.frame.height / 2)
        inputRight.zPosition = self.zPosition + 1
        
        mainOutput.position.x = self.frame.midX
        mainOutput.position.y = self.frame.height - (mainOutput.frame.height / 2)
        mainOutput.zPosition = self.zPosition + 1
        
        let label = SKLabelNode(text: labelText)
        label.color = .white
        label.position.x = self.frame.width / 2
        label.position.y = self.frame.height / 2  - label.frame.height / 2
//        label.position = self.position
        label.zPosition = 2
        addChild(label)
        
        addChild(inputLeft)
        addChild(inputRight)
        addChild(mainOutput)
    }
    
    func update() {
        if self.inputLeft.ariaPressure > 0 && self.inputRight.ariaPressure > 0 {
            mainOutput.ariaPressure = [inputLeft.ariaPressure, inputRight.ariaPressure].max() ?? 0.0
        } else {
            mainOutput.ariaPressure = 0.0
        }
    }

    static var preferredSize: CGSize {
        return .init(width: 100, height: 50)
    }
    
}
