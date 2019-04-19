//
//  TreDueBistabile.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class TreDueBistabile : SKShapeNode, ValvolaConformance {
    enum ValvolaState {
        case aperta
        case riposo
    }
    
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "3/2 Bistabile"
    }
    
    var state : ValvolaState = .riposo {
        didSet {
            if state == .aperta {
                self.outputMain.ariaPressure = self.inputAria.getMostHightInput()?.ariaPressure ?? 0
            } else {
                self.outputMain.ariaPressure = 0
            }
        }
    }
    
    var inputAria : InputOutput!
    
    var inputLeft: InputOutput!
    var inputRight: InputOutput!
    
    var outputMain: InputOutput!
    
//    var ios: Set<InputOutput> {
//        var set = Set<InputOutput>()
//        set.insert(inputAria)
//        set.insert(inputLeft)
//        set.insert(inputRight)
//        set.insert(outputMain)
//        return set
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
        self.inputAria = InputOutput(circleOfRadius: 10, valvola: self)
        
        self.inputLeft  = InputOutput(circleOfRadius: 10, valvola: self)
        self.inputRight  = InputOutput(circleOfRadius: 10, valvola: self)
        
        self.outputMain = InputOutput(circleOfRadius: 10, valvola: self)
        
        inputAria.idNumber = 0
        inputLeft.idNumber = 1
        inputRight.idNumber = 2
        outputMain.idNumber = 3
        
        let w = self.frame.size.width
        let halfWidth = w / 2
        inputAria.position.x = halfWidth + halfWidth / 2 - (inputAria.frame.width / 2)
        inputAria.position.y = 0 - (inputAria.frame.height / 2)
        inputAria.zPosition = self.zPosition + 1
        
        
        inputLeft.position.x = 0 - (inputLeft.frame.width / 2)
        inputLeft.position.y = self.frame.height / 2 - inputLeft.frame.height / 2
        inputLeft.zPosition = self.zPosition + 1
        
        inputRight.position.x = w - (inputLeft.frame.width / 2)
        inputRight.position.y = self.frame.height / 2 - inputRight.frame.height / 2
        inputRight.zPosition = self.zPosition + 1
        
        outputMain.position.x = halfWidth / 2 - outputMain.frame.width / 2
        outputMain.position.y = self.frame.height - (outputMain.frame.height / 2)
        outputMain.zPosition = self.zPosition + 1

        
        
        let label = SKLabelNode(text: labelText)
        label.color = .white
        label.position.x = self.frame.width / 2
        label.position.y = self.frame.height / 2  - label.frame.height / 2
        //        label.position = self.position
        label.zPosition = 2
        addChild(label)
        
        addChild(inputAria)
        
        addChild(inputLeft)
        addChild(inputRight)
        
        addChild(outputMain)
    }
    
    func update() {
        if self.state == .riposo {
            if self.inputLeft.ariaPressure > 0 && self.inputRight.ariaPressure <= 0 {
                self.state = .aperta
            } else {
                self.state = .riposo
            }
        } else {
            if self.inputRight.ariaPressure > 0 && self.inputLeft.ariaPressure <= 0 {
                self.state = .riposo
            } else {
                self.state = .aperta
            }
        }
    }
    
    static var preferredSize: CGSize {
        return .init(width: 200, height: 50)
    }
    
}
