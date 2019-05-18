//
//  CilindroDoppioEffetto.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class CilindroDoppioEffetto: SKShapeNode, ValvolaConformance, Movable {
    enum CyclinderState {
        case fuoriuscito
        case interno
        case animating
    }
    
//    var ios: Set<InputOutput> {
//        var set = Set<InputOutput>()
//        set.insert(inputLeft)
//        set.insert(inputRight)
//        return set
//    }
    
    var id: UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "Cilindro"
    }
    
    var inputLeft : InputOutput!
    var inputRight : InputOutput!
    
    var state : CyclinderState = .interno
    
    var pistone: SKShapeNode!
    var pistonAction: SKAction!
    
    var movingObjectCurrentLocation: CGFloat {
        return self.pistone.position.x
    }
    var movingPath: MovingPath!
    
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
        inputLeft.update()
        inputRight.update()
        
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
        
        inputLeft.idNumber = 0
        inputRight.idNumber = 1
        
        inputLeft.position.x = self.frame.width / 10
        inputLeft.position.y = 0 - inputLeft.frame.height / 2
        inputLeft.zPosition = self.zPosition + 1
        
        inputRight.position.x = self.frame.width / 10 * 9 - inputRight.frame.width
        inputRight.position.y = 0 - inputRight.frame.height / 2
        inputRight.zPosition = self.zPosition + 1
        
        
        let pistone = SKShapeNode(rect: .init(origin: .zero, size: .init(width: self.frame.width + 15, height: self.frame.height / 5)))
        pistone.zPosition = self.zPosition - 1
        pistone.position.x = 0
        pistone.position.y = self.frame.height / 2 - pistone.frame.height / 2
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
        
        let startPointPath = self.pistone.position.x
        let finishPointPath = self.pistone.position.x + 50
        self.movingPath = MovingPath(startPoint: startPointPath, endPoint: finishPointPath)
        
        let path = CGMutablePath()
        let startPoint = CGPoint(x: movingPath.startPoint, y: self.position.y)
        let finishPoint = CGPoint(x: movingPath.endPoint, y: startPoint.y)
        path.move(to: startPoint)
        path.addLine(to: finishPoint)
        
        let action = SKAction.follow(path, asOffset: true, orientToPath: false, duration: 0.3)
        self.pistonAction = action
    }
    
    static var preferredSize: CGSize {
        return CGSize(width: 200, height: 50)
    }
    
}
