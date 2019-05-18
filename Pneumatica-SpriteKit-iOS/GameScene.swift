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

enum Mode {
    case editing
    case running
    case stopped
}

class GameScene: SKScene {
    var mode: Mode = .editing
    
    var defaultBackground: UIColor!
    
    var firstSelectedIO: InputOutput?
    var secondSelectedIO: InputOutput?
    var lines: [Line] = []
    
    var trashNode : SKShapeNode?
    var loaderNode: SKShapeNode?
    
    var holdRecognizer: UILongPressGestureRecognizer!
    var tableView : UITableView!
    var dataSource : UITableViewDataSource!
    
    var editinMode : EditingMode!
    
    var valvole: [ValvolaConformance] = []
    var selectedValvola : ValvolaConformance?
    var valvoleLayoutChanged: Bool = false
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.anchorPoint = .zero
        
        self.defaultBackground = self.backgroundColor
        
        self.editinMode = EditingMode(sceneFrame: self.frame)
        
        self.trashNode = SKShapeNode(circleOfRadius: 25)
        trashNode!.fillColor = .red
        trashNode!.zPosition = 1
        trashNode!.name = "Trash"
        trashNode!.position.x = self.view!.frame.width - trashNode!.frame.width / 2
        trashNode!.position.y = 0 + trashNode!.frame.height / 2
        addChild(trashNode!)
        
        self.loaderNode = SKShapeNode(circleOfRadius: 25)
        loaderNode!.fillColor = .red
        loaderNode!.zPosition = 1
        loaderNode!.name = "Loader"
        loaderNode!.position.x = self.view!.frame.width - loaderNode!.frame.width / 2
        loaderNode!.position.y = self.frame.height - loaderNode!.frame.height
        addChild(loaderNode!)
        
        self.tableView = UITableView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(BoldCell.self, forCellReuseIdentifier: "BoldCell")
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        
        self.holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdPoint(_:)))
        self.view?.addGestureRecognizer(self.holdRecognizer)
        
        
        NotificationCenter.default.addObserver(forName: .sceneModeChanged, object: nil, queue: .main) { (notif) in
            guard let mode = notif.object as? Mode else { return }
            self.mode = mode
            print("mode changed in: \(mode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {

        for valvola in valvole {
            valvola.ios.forEach { $0.update() }
            valvola.update()
        }

        lines.forEach { $0.update() }
        
        if valvoleLayoutChanged {
            lines.forEach { drawLine(line: $0) }
            valvoleLayoutChanged = false
        }
    }
    
    @objc func holdPoint(_ recognizer: UILongPressGestureRecognizer) {
        let origPoint = recognizer.location(in: self.view!)
        let newPoint = convertPoint(fromView: origPoint)//convert(origPoint, to: self)
        
        if let node = self.nodes(at: newPoint).first as? AcceptsMovableInput {
            if editinMode.state == .disabled {
                self.backgroundColor = .purple
                editinMode.state = .active
                editinMode.selectedValvolaWithMovableInput = node
                self.scene?.view?.addSubview(editinMode.editView)
            }
            return
        } else if self.nodes(at: newPoint).first?.name == "Trash" {
            let nodes = scene?.children.compactMap { $0 as? ValvolaConformance } ?? []
            let saver = Saver(circuitName: "TestCircuitName", nodes: nodes, scene: scene!)
            do {
                try saver.save(to: "circuit.json")
            } catch {
                UIApplication.shared.keyWindow?.rootViewController?.showAlert(withTitle: "Errore", andMessage: "\(error)")
            }
        } else if self.nodes(at: newPoint).first?.name == "Loader" {
            do {
                let loader = try Loader(fileName: "circuit.json", scene: self.scene!)
                loader.load()
            } catch {
                UIApplication.shared.keyWindow?.rootViewController?.showAlert(withTitle: "Errore", andMessage: "\(error)")
            }
            
        } else {
            if editinMode.state == .active {
                editinMode.reset()
                self.backgroundColor = self.defaultBackground
            } else {
                showTableView()
            }
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
        
        if editinMode.state == .active {
            if let movableObject = nodes.first as? Movable {
                editinMode.selectedInput = movableObject
            }
            if editinMode.selectedInput != nil && editinMode.selectedValvolaWithMovableInput != nil {
                editinMode.selectedValvolaWithMovableInput?.movableInput = editinMode.selectedInput
                editinMode.selectedValvolaWithMovableInput?.listenValue = editinMode.editView.sliderValue
                editinMode.reset()
                self.backgroundColor = self.defaultBackground
            }
            return
        }
        
        
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
                    removeLine(from: firstIO, to: secondIO)
                } else {
                    createLine(from: firstIO, to: secondIO)
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
        line.zPosition = 0
        line.strokeColor = SKColor.red
    }
    
    func createLine(from firstIO: InputOutput, to secondIO: InputOutput) {
        let line = Line()
        line.fromInput = firstIO
        line.toOutput = secondIO
        
        drawLine(line: line)
        self.lines.append(line)
        addChild(line)
        
        firstIO.addWire(from: secondIO)
        
        firstIO.fillColor = .blue
        secondIO.fillColor = .blue
    }
    
    func removeLine(from firstIO: InputOutput, to secondIO: InputOutput) {
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
            newNode.fillColor = self.defaultBackground
            newNode.position.x = self.frame.width / 2
            newNode.position.y = self.frame.height / 2
            newNode.zPosition = 1
            self.addChild(newNode)
            valvole.append(newNode)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
