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
    
    var labelText: String {
        return "AND"
    }
    
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
            PneumaticaRuntime.shared.sendAria(to: mainOutput.inputsConnected, from: mainOutput)
//            self.fillColor = .green
        } else {
            mainOutput.ariaPressure = 0.0
            PneumaticaRuntime.shared.stopSendingAria(to: mainOutput.inputsConnected, from: mainOutput)
//            self.fillColor = .clear
        }
    }

}

class ValvolaOR : ValvolaAnd {
    override var labelText: String {
        return "OR"
    }
    
    override func update() {
        if inputLeft.ariaPressure > 0 || inputRight.ariaPressure > 0 {
            mainOutput.ariaPressure = [inputLeft.ariaPressure, inputRight.ariaPressure].max() ?? 0.0
            PneumaticaRuntime.shared.sendAria(to: mainOutput.inputsConnected, from: mainOutput)
        } else {
            mainOutput.ariaPressure = 0.0
            PneumaticaRuntime.shared.stopSendingAria(to: mainOutput.inputsConnected, from: mainOutput)
        }
    }
}

class GruppoFRL : SKShapeNode, ValvolaConformance {
    var id: UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    var labelText: String {
        return "FRL"
    }
    
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
        
        let label = SKLabelNode(text: self.labelText)
        label.color = .white
        label.position.x = self.frame.width / 2
        label.position.y = self.frame.height / 2  - label.frame.height / 2
        label.zPosition = 2
        
        addChild(label)
        addChild(onlyOutput)
    }
    
    
}

class CilindroDoppioEffetto: SKShapeNode, ValvolaConformance {
    var id: UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "CDE"
    }
    
    var inputLeft : InputOutput!
    var inputRight : InputOutput!
    
    var state : CyclinderState = .interno
    
    var pistone: SKShapeNode!
    var pistonAction: SKAction!
    
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
        switch state {
        case .interno:
            if inputLeft.ariaPressure > 0 && inputRight.ariaPressure <= 0 {
                self.pistone.run(pistonAction)
                self.state = .fuoriuscito
            }
        case .fuoriuscito:
            if inputRight.ariaPressure > 0 && inputLeft.ariaPressure <= 0 {
                self.pistone.run(pistonAction.reversed())
                self.state = .interno
            }
        case .animating: break // da fare in futuro se necessario
        }
    }
    
    func enable() {
        self.inputLeft = InputOutput(circleOfRadius: 10, valvola: self)
        self.inputRight = InputOutput(circleOfRadius: 10, valvola: self)
        
        inputLeft.position.x = self.frame.width / 10
        inputLeft.position.y = 0 - inputLeft.frame.height / 2
        inputLeft.zPosition = self.zPosition + 1
        
        inputRight.position.x = self.frame.width / 10 * 9 - inputRight.frame.width
        inputRight.position.y = 0 - inputRight.frame.height / 2
        inputRight.zPosition = self.zPosition + 1
        
        
        let pistone = SKShapeNode(rect: .init(x: 0, y: 0, width: self.frame.width + 15, height: self.frame.height / 5))
        pistone.zPosition = self.zPosition - 1
        pistone.position.x = self.frame.minX
        pistone.position.y = self.frame.midY - pistone.frame.height / 2
        self.pistone = pistone
        
        let label = SKLabelNode(text: self.labelText)
        label.color = .white
        label.position.x = self.frame.width / 2
        label.position.y = self.frame.height / 2  - label.frame.height / 2
        label.zPosition = 2
        
        addChild(label)
        addChild(inputLeft)
        addChild(inputRight)
        addChild(pistone)
        
        let path = CGMutablePath()
        let startPoint = CGPoint(x: self.frame.minX, y: pistone.position.y - pistone.frame.height * 1.5)
        let finishPoint = CGPoint(x: startPoint.x + 50, y: startPoint.y)
        path.move(to: startPoint)
        path.addLine(to: finishPoint)
        
        let action = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 0.3)
        self.pistonAction = action
    }
    
}

class Line: SKShapeNode {
    var fromInput : InputOutput!
    var toOutput: InputOutput!
}
