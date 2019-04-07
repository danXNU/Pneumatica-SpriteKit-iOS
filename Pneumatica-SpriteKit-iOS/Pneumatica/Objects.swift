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
        
        inputLeft.parentValvola = self
        inputRight.parentValvola = self
        mainOutput.parentValvola = self
        
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
        
        let label = SKLabelNode(text: "AND")
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
            PneumaticaRuntime.shared.sendAria(to: mainOutput.inputsConnected, from: mainOutput)
//            self.fillColor = .green
        } else {
            PneumaticaRuntime.shared.stopSendingAria(to: mainOutput.inputsConnected, from: mainOutput)
//            self.fillColor = .clear
        }
    }

}

class GruppoFRL : SKShapeNode, ValvolaConformance {
    var id: UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var isActive : Bool = true
    var onlyOutput : InputOutput!
    
    init(size: CGSize) {
        super.init()
        self.fillColor = .clear
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        enable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        onlyOutput.ariaPressure = 2.0
        PneumaticaRuntime.shared.sendAria(to: onlyOutput.inputsConnected, from: onlyOutput)
    }
    
    func enable() {
        self.onlyOutput = InputOutput(circleOfRadius: 10, valvola: self)
        onlyOutput.parentValvola = self
        
        onlyOutput.position.x = self.frame.width / 2 - onlyOutput.frame.width / 2
        onlyOutput.position.y = self.frame.height - onlyOutput.frame.height / 2
        onlyOutput.zPosition = self.zPosition + 1
        
        let label = SKLabelNode(text: "FRL")
        label.color = .white
        label.position.x = self.frame.width / 2
        label.position.y = self.frame.height / 2  - label.frame.height / 2
        label.zPosition = 2
        
        addChild(label)
        addChild(onlyOutput)
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
            if inputLeft.ariaPressure > 0 && inputRight.ariaPressure <= 0 {
                //animation
                self.state = .fuoriuscito
            }
        case .fuoriuscito:
            if inputRight.ariaPressure > 0 && inputLeft.ariaPressure <= 0 {
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
