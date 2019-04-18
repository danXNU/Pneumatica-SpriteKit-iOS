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
    
    let cilindro = CilindroDoppioEffetto(size: .init(width: 200, height: 50))
    let finecorsa = Finecorsa(size: .init(width: 200, height: 50))
    let frl = GruppoFRL(size: .init(width: 100, height: 50))
    
    var firstSelectedIO: InputOutput?
    var secondSelectedIO: InputOutput?
    var lines: [Line] = []
    
    var trashNode : SKShapeNode?
    
    var holdRecognizer: UILongPressGestureRecognizer!
    var tableView : UITableView!
    var dataSource : UITableViewDataSource!
    
    
    var selectedValvola : ValvolaConformance?
    var valvoleLayoutChanged: Bool = false
    var isEditingMode : Bool = false
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.anchorPoint = .zero
        
        self.trashNode = SKShapeNode(circleOfRadius: 50)
        trashNode!.fillColor = .red
        trashNode!.zPosition = 1
        trashNode!.name = "Trash"
        trashNode!.position.x = self.view!.frame.width - trashNode!.frame.width / 2
        trashNode!.position.y = 0 + trashNode!.frame.height / 2
        addChild(trashNode!)
        
        self.tableView = UITableView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(BoldCell.self, forCellReuseIdentifier: "BoldCell")
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        
        self.holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdPoint(_:)))
        self.view?.addGestureRecognizer(self.holdRecognizer)
        
        
        frl.name = "FRL"
        frl.position = CGPoint(x: 200, y: 200)
        frl.zPosition = 1
        addChild(frl)
        
        cilindro.name = "Cilindro"
        cilindro.position = CGPoint(x: 200, y: 500)
        cilindro.zPosition = 1
        cilindro.fillColor = self.scene!.backgroundColor
        addChild(cilindro)
    
        
        finecorsa.name = "Finecorsa"
        finecorsa.position = CGPoint(x: 20, y: 150)
        finecorsa.zPosition = 1
        finecorsa.inputLeft = self.cilindro
        addChild(finecorsa)
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
        
        if let _ = self.nodes(at: newPoint).first as? Editable {
            let alert = UIAlertController(title: "Test", message: "It works!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        } else {
            showTableView()
        }
    }
    

    fileprivate func makeExplosion(_ valvola: ValvolaConformance) {
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            let defaultVector = explosion.particlePositionRange
            let width = valvola.frame.width
            
            explosion.particlePositionRange = CGVector(dx: width, dy: defaultVector.dy)
            explosion.zPosition = 1
            explosion.position.x = valvola.position.x + valvola.frame.width / 2
            explosion.position.y = valvola.frame.height
            addChild(explosion)
            
            let removeAction = SKAction.removeFromParent()
            let waitAction = SKAction.wait(forDuration: 1.5)
            let fullAction = SKAction.sequence([waitAction, removeAction])
            explosion.run(fullAction)
            valvola.run(fullAction)
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
        
            if let firstValvola = firstSelectedIO?.parentValvola, let secondValvola = secondSelectedIO?.parentValvola {
                if firstValvola == secondValvola {
                    print("Non puoi collegare un filo alla stessa valvola")
                    resetTouches()
                    return
                }
            }
            
            
            if let firstIO = firstSelectedIO, let secondIO = secondSelectedIO {
                if firstIO.inputsConnected.contains(secondIO) && secondIO.inputsConnected.contains(firstIO) {
                    removeLine()
                } else {
                    createLine()
                }
                resetTouches()
            }
            
            
        } else if let valvola = nodes.first as? ValvolaConformance {
            selectedValvola?.strokeColor = .white
            selectedValvola = valvola
            selectedValvola?.strokeColor = .red
            
        } else {
            resetTouches()
            hideTableView()
        }
        
        if let valvola = selectedValvola, let trashNode = self.trashNode {
            if valvola.intersects(trashNode) {
                makeExplosion(valvola)
                selectedValvola = nil
            }
        }
        
    }
    
    func showTableView() {
        let width = self.size.width / 2
        let height = self.size.height
        
        let rect = CGRect(origin: .zero, size: .init(width: width, height: height))
        self.tableView.frame = rect
        self.view?.addSubview(self.tableView)
        self.dataSource = ObjectCreationDataSource()
        tableView.dataSource = self.dataSource
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func hideTableView() {
        self.tableView.removeFromSuperview()
    }
    
    func resetTouches() {
        selectedValvola?.strokeColor = .white
        selectedValvola = nil
        firstSelectedIO = nil
        secondSelectedIO = nil
        
        for valvola in self.children where valvola is ValvolaConformance {
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
        
        let startPosition = convert(startPoint, from: line.fromInput!.parentValvola!)
        let finishPosition = convert(finishPoint, from: line.toOutput!.parentValvola!)
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideTableView()
        if let dataSource = self.dataSource as? ObjectCreationDataSource {
            let newNode = dataSource.createInstanceOf(index: indexPath.row)
            newNode.position.x = self.frame.width / 2
            newNode.position.y = self.frame.height / 2
            newNode.zPosition = 1
            self.addChild(newNode)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
