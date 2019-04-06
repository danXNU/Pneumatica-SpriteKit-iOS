//
//  Objects.swift
//  Pneumatica
//
//  Created by Dani Tox on 02/04/2019.
//

import SpriteKit

class ValvolaAnd : SKShapeNode, ValvolaConformance {
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var inputLeft : InputOutput!
    var inputRight: InputOutput!
    
    var mainOutput: InputOutput!
    
    init(size: CGSize) {
        super.init()
        
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
        
        inputLeft.parentValvola = self
        inputRight.parentValvola = self
        mainOutput.parentValvola = self
        
        inputLeft.fillColor = self.fillColor
        inputRight.fillColor = self.fillColor
        mainOutput.fillColor = self.fillColor
        
        let w = self.frame.width
        inputLeft.position = CGPoint(x: self.frame.minX, y: 0)
        inputLeft.zPosition = self.zPosition + 1
        
        inputRight.position = CGPoint(x: w, y: 0)
        inputRight.zPosition = self.zPosition + 1
        
        mainOutput.position = CGPoint(x: self.frame.midX, y: self.frame.height)
        mainOutput.zPosition = self.zPosition + 1
        
        addChild(inputLeft)
        addChild(inputRight)
        addChild(mainOutput)
    }
    
    func update() {
        if inputLeft == nil || mainOutput == nil || inputRight == nil {
            self.enable()
        }
//
//        if case AriaType.present(_) = self.inputLeft.ariaValue, case AriaType.present(_) = self.inputRight.ariaValue {
//            PneumaticaRuntime.shared.sendAria(to: mainOutput.inputsConnected, from: mainOutput)
//        } else {
//            PneumaticaRuntime.shared.stopSendingAria(to: mainOutput.inputsConnected, from: mainOutput)
//        }
    }
}

class GruppoFRL : SKSpriteNode, ValvolaConformance {
    var id: UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var isActive : Bool = true
    var onlyOutput : InputOutput!
    
    func update() {
        PneumaticaRuntime.shared.sendAria(to: onlyOutput.inputsConnected, from: onlyOutput)
    }
    
    func enable() {
        self.onlyOutput = InputOutput(circleOfRadius: 10, valvola: self)
        onlyOutput.parentValvola = self
    }
    
}

class CilindroDoppioEffetto: SKSpriteNode, ValvolaConformance {
    var id: UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var inputLeft : InputOutput!
    var inputRight : InputOutput!
    
    var state : CyclinderState = .interno
    
    func update() {
        switch state {
        case .interno:
            if case AriaType.present(_) = inputLeft.ariaValue, case AriaType.notPresent = inputRight.ariaValue {
                //animation
                self.state = .fuoriuscito
            }
        case .fuoriuscito:
            if case AriaType.present(_) = inputRight.ariaValue, case AriaType.notPresent = inputLeft.ariaValue {
                //animation
                self.state = .interno
            }
        case .animating: break // da fare in futuro se necessario
        }
    }
    
    func enable() {
        self.inputLeft = InputOutput(circleOfRadius: 10, valvola: self)
        self.inputRight = InputOutput(circleOfRadius: 10, valvola: self)
    }
    
}

class Line: SKShapeNode {
    var fromInput : InputOutput!
    var toOutput: InputOutput!
}
