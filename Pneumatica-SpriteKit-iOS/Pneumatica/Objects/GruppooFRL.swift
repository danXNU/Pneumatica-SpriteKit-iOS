//
//  GruppooFRL.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class GruppoFRL : SKShapeNode, ValvolaConformance {
    var id: UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    var labelText: String {
        return "FRL"
    }
    
    var isActive : Bool = true
    var onlyOutput : InputOutput!
    
    var ios: Set<InputOutput> {
        var set = Set<InputOutput>()
        set.insert(onlyOutput)
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
    
    func update() {
        onlyOutput.ariaPressure = 2.0
        //        PneumaticaRuntime.shared.sendAria(to: onlyOutput.inputsConnected, from: onlyOutput)
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
