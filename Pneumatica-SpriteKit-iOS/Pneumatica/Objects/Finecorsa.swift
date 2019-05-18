//
//  Finecorsa.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class Finecorsa: SKShapeNode, ValvolaConformance, AcceptsMovableInput, Editable {
    enum ValvolaState {
        case aperta
        case chiusa
    }
    
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "Finecorsa"
    }
    
    var listenValue: Float = 0
    
    var state : ValvolaState = .chiusa {
        didSet {
            switch state {
            case .chiusa:
                self.mainOutput.ariaPressure = 0
            case .aperta:
                self.mainOutput.ariaPressure = self.inputAria.getMostHightInput()?.ariaPressure ?? 0
            }
        }
    }
    
    var inputAria : InputOutput!
    var movableInput: Movable?
    var mainOutput: InputOutput!
    
//    var ios: [InputOutput] {
//        return [inputAria, mainOutput]
//    }
    
    required init(size: CGSize) {
        super.init()
        self.fillColor = .clear
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        self.zPosition = 1
        enable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enable() {
        
        self.inputAria = InputOutput(circleOfRadius: 10, valvola: self)
        self.mainOutput = InputOutput(circleOfRadius: 10, valvola: self)
        
        inputAria.idNumber = 0
        mainOutput.idNumber = 1
        
        let w = self.frame.size.width
        
        let halfWidth = w / 2
        inputAria.position.x = halfWidth + halfWidth / 2 - (inputAria.frame.width / 2)
        inputAria.position.y = 0 - (inputAria.frame.height / 2)
        inputAria.zPosition = self.zPosition + 1
        
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
        
        addChild(inputAria)
        addChild(mainOutput)
    }
    
    func update() {
        guard let movableInput = self.movableInput else {
            self.state = .chiusa
            return
        }
        var movingPoint = movableInput.movingPointValue
        if movingPoint < 0 { movingPoint = 0 }
        if movingPoint > 1 { movingPoint = 1 }
        let roundedValue = roundf(Float(10.0 * movingPoint)) / 10.0
        
        
        if roundedValue == listenValue {
            self.state = .aperta
        } else {
            self.state = .chiusa
        }
    }
    
    
    static var preferredSize: CGSize {
        return .init(width: 200, height: 50)
    }
}

