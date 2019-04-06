//
//  GameScene.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 06/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let valvola = ValvolaAnd(size: .init(width: 200, height: 100))
    let test = ValvolaAnd(size: .init(width: 200, height: 100))
    
    var firstSelectedIO: InputOutput?
    var secondSelectedIO: InputOutput?
    
    var selectedValvola : SKNode?
    var valvoleLayoutChanged: Bool = false
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.anchorPoint = .zero
        
        valvola.name = "Valvola And"
        valvola.position = CGPoint(x: 0, y: 0)
        valvola.zPosition = 1
        addChild(valvola)
        
        test.name = "Asd"
        test.position = CGPoint(x: 100, y: 100)
        test.zPosition = 1
        addChild(test)
        
    }
    
    var lastUpdate : TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
//        defer { lastUpdate = currentTime }
//
//        for node in self.scene?.children ?? [] {
//            guard let realNode = node as? ValvolaConformance else { continue }
//            realNode.update()
//        }
        if valvoleLayoutChanged {
            let lines = self.children.compactMap { $0 as? Line }
            lines.forEach { (line) in
                drawLine(line: line)
            }
            valvoleLayoutChanged = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        let nodes = self.nodes(at: touchPoint!)
        if let clickedIO = nodes.first as? InputOutput {
            if firstSelectedIO == nil { firstSelectedIO = clickedIO }
            else if secondSelectedIO == nil { secondSelectedIO = clickedIO }
        
            clickedIO.fillColor = .red
            createLine()
        } else if let valvola = nodes.first as? SKNode & ValvolaConformance {
            (selectedValvola as? SKShapeNode)?.strokeColor = .white
            selectedValvola = valvola
            (selectedValvola as? SKShapeNode)?.strokeColor = .red
        } else {
            (selectedValvola as? SKShapeNode)?.strokeColor = .white
            selectedValvola = nil
            firstSelectedIO = nil
            secondSelectedIO = nil
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            
            selectedValvola?.position.x = touchPoint.x - 100
            selectedValvola?.position.y = touchPoint.y - 50
        }
        valvoleLayoutChanged = true
    }
    
    func drawLine(line: Line) {
        let path = CGMutablePath()
        
        var startPoint = line.fromInput!.position
        var finishPoint = line.toOutput!.position
        
        startPoint.x += (line.fromInput.frame.width / 2)
        startPoint.y += (line.fromInput.frame.height / 2)
        
        finishPoint.x += (line.toOutput.frame.width / 2)
        finishPoint.y += (line.toOutput.frame.height / 2)
        
        let startPosition = convert(startPoint, from: line.fromInput!.parentValvola! as! SKNode)
        let finishPosition = convert(finishPoint, from: line.toOutput!.parentValvola! as! SKNode)
        
        path.move(to: startPosition)
        path.addLine(to: finishPosition)
        
        line.path = path
        line.zPosition = 2
        line.strokeColor = SKColor.red
    }
    
    func createLine() {
        if firstSelectedIO != nil && secondSelectedIO != nil {
            let line = Line()
            line.fromInput = firstSelectedIO
            line.toOutput = secondSelectedIO
            
            drawLine(line: line)
            
            addChild(line)
            
            firstSelectedIO?.addWire(from: secondSelectedIO!)
            
            firstSelectedIO?.fillColor = .blue
            secondSelectedIO?.fillColor = .blue
            firstSelectedIO = nil
            secondSelectedIO = nil
        }
    }
    
}
