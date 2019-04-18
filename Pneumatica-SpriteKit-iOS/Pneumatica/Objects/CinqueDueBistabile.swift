//
//  CinqueDueBistabile.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class CinqueDueBistabile : SKShapeNode, ValvolaConformance {
    enum ValvolaState {
        case aperta
        case riposo
    }
    
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "5/2 Bistabile"
    }
    
    var state : ValvolaState = .riposo {
        didSet {
            if state == .aperta {
                self.outputLeft.ariaPressure = self.inputAria.getMostHightInput()?.ariaPressure ?? 0
                self.outputRight.ariaPressure = 0
            } else {
                self.outputRight.ariaPressure = self.inputAria.getMostHightInput()?.ariaPressure ?? 0
                self.outputLeft.ariaPressure = 0
            }
        }
    }
    
    var inputAria : InputOutput!
    
    var inputLeft: InputOutput!
    var inputRight: InputOutput!
    
    var outputLeft: InputOutput!
    var outputRight: InputOutput!
    
    var ios: Set<InputOutput> {
        var set = Set<InputOutput>()
        set.insert(inputAria)
        set.insert(inputLeft)
        set.insert(inputRight)
        set.insert(outputLeft)
        set.insert(outputRight)
        return set
    }
    
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
        
        self.outputLeft = InputOutput(circleOfRadius: 10, valvola: self)
        self.outputRight = InputOutput(circleOfRadius: 10, valvola: self)
        
        inputAria.parentValvola = self
        
        inputLeft.parentValvola = self
        inputRight.parentValvola = self
        
        outputLeft.parentValvola = self
        outputRight.parentValvola = self
        
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
        
        outputLeft.position.x = halfWidth / 2 - outputLeft.frame.width / 2
        outputLeft.position.y = self.frame.height - (outputLeft.frame.height / 2)
        outputLeft.zPosition = self.zPosition + 1
        
        outputRight.position.x = halfWidth + halfWidth / 2 - outputRight.frame.width / 2
        outputRight.position.y = self.frame.height - (outputRight.frame.height / 2)
        outputRight.zPosition = self.zPosition + 1
        
        
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
        
        addChild(outputLeft)
        addChild(outputRight)
        
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
