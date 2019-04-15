//
//  Pulsante.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class Pulsante : SKShapeNode, ValvolaConformance {
    enum PulsanteState {
        case premuto
        case riposo
    }
    
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "Pulsante"
    }
    
    var state : PulsanteState = .riposo {
        didSet {
            if state == .premuto {
                self.outputMain.ariaPressure = inputAria.getMostHightInput()?.ariaPressure ?? 0
            } else {
                self.outputMain.ariaPressure = 0
            }
        }
    }
    
    var inputAria : InputOutput!
    var outputMain: InputOutput!
    var inputPulsante : PressableInput!
    
    var ios: Set<InputOutput> {
        var set = Set<InputOutput>()
        set.insert(inputAria)
        set.insert(outputMain)
        return set
    }
    
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
        self.inputAria = InputOutput(circleOfRadius: 10, valvola: self)
        self.outputMain = InputOutput(circleOfRadius: 10, valvola: self)
        self.inputPulsante = PressableInput(size: .init(width: 30, height: 30), valvola: self)
        
        
        let w = self.frame.size.width
        let halfWidth = w / 2
        inputAria.position.x = halfWidth - (inputAria.frame.width / 2)
        inputAria.position.y = 0 - (inputAria.frame.height / 2)
        inputAria.zPosition = self.zPosition + 1
        
        outputMain.position.x = halfWidth - outputMain.frame.width / 2
        outputMain.position.y = self.frame.height - (outputMain.frame.height / 2)
        outputMain.zPosition = self.zPosition + 1
        
        inputPulsante.position.x = 0 - inputPulsante.frame.width / 2
        inputPulsante.position.y = self.frame.height / 2 - inputPulsante.frame.height / 2
        inputPulsante.zPosition = self.zPosition + 1
        
        
        let label = SKLabelNode(text: labelText)
        label.color = .white
        label.position.x = self.frame.width / 2
        label.position.y = self.frame.height / 2  - label.frame.height / 2
        //        label.position = self.position
        label.zPosition = 2
        addChild(label)
        
        addChild(inputAria)
        addChild(outputMain)
        addChild(inputPulsante)
        
    }
    
    func update() {
        if self.inputPulsante.ariaPressure > 0 {
            self.state = .premuto
        } else {
            self.state = .riposo
        }
    }
    
}
