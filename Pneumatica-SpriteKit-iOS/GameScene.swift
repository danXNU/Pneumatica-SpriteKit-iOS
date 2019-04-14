//
//  GameScene.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 06/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene {
    
    let and = ValvolaAnd(size: .init(width: 100, height: 50))
    let or = ValvolaOR(size: .init(width: 100, height: 50))
    let frl = GruppoFRL(size: .init(width: 100, height: 100))
    let cilindro = CilindroDoppioEffetto(size: .init(width: 200, height: 50))
    let treDueNC = TreDueMonostabileNC(size: .init(width: 200, height: 50))
    let timer = SpriteTimer(size: .init(width: 80, height: 50))
    let cinqueDue = CinqueDueBistabile(size: .init(width: 250, height: 50))
    let pulsante = Pulsante(size: .init(width: 150, height: 50))
    
    var firstSelectedIO: InputOutput?
    var secondSelectedIO: InputOutput?
    var lines: [Line] = []
    
    var holdRecognizer: UILongPressGestureRecognizer!
    var tableView : UITableView!
    
    var selectedValvola : SKNode?
    var valvoleLayoutChanged: Bool = false
    
    var dataSource : ObjectsListDataSource!
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.anchorPoint = .zero
        
        self.tableView = UITableView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.backgroundColor = .white
        self.tableView.delegate = self
        
        self.holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdPoint(_:)))
        self.view?.addGestureRecognizer(self.holdRecognizer)
        
        and.name = "Valvola And"
        and.position = CGPoint(x: 0, y: 0)
        and.zPosition = 1
        addChild(and)
        
        or.name = "OR"
        or.position = CGPoint(x: 200, y: 400)
        or.zPosition = 1
        addChild(or)
        
        frl.name = "FRL"
        frl.position = CGPoint(x: 200, y: 200)
        frl.zPosition = 1
        addChild(frl)
        
        cilindro.name = "Cilindro"
        cilindro.position = CGPoint(x: 200, y: 500)
        cilindro.zPosition = 1
        cilindro.fillColor = self.scene!.backgroundColor
        addChild(cilindro)
        
        treDueNC.name = "3/2 Monostabile NC"
        treDueNC.position = CGPoint(x: 200, y: 100)
        treDueNC.zPosition = 1
        addChild(treDueNC)
        
        timer.name = "Timer"
        timer.position = CGPoint(x: 100, y: 50)
        timer.zPosition = 1
        addChild(timer)
        
        cinqueDue.name = "5/2 Bistabile"
        cinqueDue.position = CGPoint(x: 0, y: 500)
        cinqueDue.zPosition = 1
        addChild(cinqueDue)
        
        pulsante.name = "Pulsante"
        pulsante.position = CGPoint(x: 50, y: 400)
        pulsante.zPosition = 1
        addChild(pulsante)
    }
    
    var lastUpdate : TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
//        defer { lastUpdate = currentTime }
//
        for node in self.scene?.children ?? [] {
            guard let realNode = node as? ValvolaConformance else { continue }
            realNode.ios.forEach { $0.update() }
            realNode.update()
        }
        lines.forEach { $0.update() }
        
        if valvoleLayoutChanged {
            let lines = self.children.compactMap { $0 as? Line }
            lines.forEach { (line) in
                drawLine(line: line)
            }
            valvoleLayoutChanged = false
        }
    }
    
    @objc func holdPoint(_ recognizer: UILongPressGestureRecognizer) {
        let origPoint = recognizer.location(in: self.view!)
        let newPoint = convertPoint(fromView: origPoint)//convert(origPoint, to: self)
        
        if let node = self.nodes(at: newPoint).first {
            
        } else {
            showTableView()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        let nodes = self.nodes(at: touchPoint!)
        if let tappableIO = nodes.first as? Tappable {
            tappableIO.tapped()
        } else if let clickedIO = nodes.first as? InputOutput {
            if firstSelectedIO == nil { firstSelectedIO = clickedIO }
            else if secondSelectedIO == nil { secondSelectedIO = clickedIO }
        
            if (firstSelectedIO?.parentValvola as? SKNode) == (secondSelectedIO?.parentValvola as? SKNode) {
                print("Non puoi collegare un filo alla stessa valvola")
                resetTouches()
                return
            }
            
            if let firstIO = firstSelectedIO, let secondIO = secondSelectedIO {
                if firstIO.inputsConnected.contains(secondIO) && secondIO.inputsConnected.contains(firstIO) {
                    removeLine()
                } else {
                    createLine()
                }
                resetTouches()
            }
            
            
        } else if let valvola = nodes.first as? SKNode & ValvolaConformance {
            (selectedValvola as? SKShapeNode)?.strokeColor = .white
            selectedValvola = valvola
            (selectedValvola as? SKShapeNode)?.strokeColor = .red
        } else {
            resetTouches()
            hideTableView()
        }
        
    }
    
    func showTableView() {
        let rect = CGRect(x: 0, y: 0, width: self.view!.frame.width, height: self.view!.frame.height / 2)
        self.tableView.frame = rect
        self.view?.addSubview(self.tableView)
        self.dataSource = ObjectsListDataSource(objects: self.lines)
        tableView.dataSource = self.dataSource
        tableView.reloadData()
    }
    
    func hideTableView() {
        self.tableView.removeFromSuperview()
    }
    
    func resetTouches() {
        (selectedValvola as? SKShapeNode)?.strokeColor = .white
        selectedValvola = nil
        firstSelectedIO = nil
        secondSelectedIO = nil
        
        for valvola in self.children where valvola is ValvolaConformance & SKNode {
            for input in valvola.children where input is InputOutput {
                let obj = input as! InputOutput
                obj.fillColor = obj.idleColor
            }
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
        
        var keyPointes : [CGPoint] = []
        var startHolder = startPosition
        while startHolder != finishPosition {
            if startHolder.x != finishPosition.x {
                startHolder.x = finishPosition.x
                keyPointes.append(startHolder)
            }
            if startHolder.y != finishPosition.y {
                startHolder.y = finishPosition.y
                keyPointes.append(startHolder)
            }
        }
        
        path.move(to: startPosition)
        for keyPoint in keyPointes {
            path.addLine(to: keyPoint)
        }
//        path.addLine(to: finishPosition)
        
        line.path = path
        line.zPosition = 1
        line.strokeColor = SKColor.red
    }
    
    func createLine() {
        if firstSelectedIO != nil && secondSelectedIO != nil {
            let line = Line()
            line.fromInput = firstSelectedIO
            line.toOutput = secondSelectedIO
            
            drawLine(line: line)
            self.lines.append(line)
            addChild(line)
            
            firstSelectedIO?.addWire(from: secondSelectedIO!)
            
            firstSelectedIO?.fillColor = .blue
            secondSelectedIO?.fillColor = .blue
            firstSelectedIO = nil
            secondSelectedIO = nil
        }
    }
    
    func removeLine() {
        guard let firstIO = firstSelectedIO else { return }
        guard let secondIO = secondSelectedIO else { return }
        
        let line = lines.first { (line) -> Bool in
            if line.fromInput == firstIO && line.toOutput == secondIO {
                return true
            } else if line.fromInput == secondIO && line.toOutput == firstIO {
                return true
            } else {
                return false
            }
        }
        
        if let lineSelected = line {
            self.lines.removeAll(where: { $0 == lineSelected })
            firstIO.removeWire(secondIO)
            let fadeAction = SKAction.fadeOut(withDuration: 0.3)
            let removeAction = SKAction.removeFromParent()
            
            let compoundAction = SKAction.sequence([fadeAction, removeAction])
            lineSelected.run(compoundAction)
        }
    }
    
}

extension GameScene : UITableViewDelegate {
    
}
