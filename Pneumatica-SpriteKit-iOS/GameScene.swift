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
import AVFoundation
import DXPneumatic

class GameScene: SKScene {
    var mode: Mode = .running
    
    var genericAgent: GenericAgent!
    
    var defaultBackground: UIColor!
    
    var lines: [Line] = []
    
    var holdRecognizer: UILongPressGestureRecognizer!
    
    var editinMode : EditingMode!
    
    var valvoleLayoutChanged: Bool = false
    
    var runtime: IPRuntime = IPRuntime(startingPoint: [])
    var newValvoleNodes: [UIValvola] = []
    
    let cameraNode = SKCameraNode()
    
    //MARK: - Lifecycle
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.anchorPoint = .zero
        
        self.defaultBackground = self.backgroundColor
        
        self.editinMode = EditingMode(sceneFrame: self.frame)

        
        self.holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdPoint(_:)))
        self.view?.addGestureRecognizer(self.holdRecognizer)
        
        self.camera = cameraNode
        
        self.runtime.start()
        
        self.genericAgent?.valvolaCreationCompletion = { valvola in
            let node = valvola
            self.newValvoleNodes.append(node)
            self.runtime.addInCircuit(valvola: node.valvolaModel, hasToInitialize: false)
            if let startingPoint = node as? DXPneumatic.GruppoFRL {
                self.runtime.addStartingPoint(startingPoint.valvolaModel)
            }

            if let observable = node as? DXPneumatic.ChangeListener {
                let listener = Listener(uiObject: observable, model: node.valvolaModel)
                self.runtime.observables.append(listener)
            }

            self.present(valvola: node)
        }
        
        self.genericAgent.valvolaRemoveAction = { valvola in
            self.newValvoleNodes.removeAll { valvola == $0 }
//            self.removeFromParent()
            valvola.removeFromParent()
        }
        
        self.genericAgent.valvolaSelectionChanged = { valvola, newState in
            if newState == true {
                guard let sprite = valvola as? SKShapeNode else { return }
                sprite.strokeColor = .blue
            } else {
                guard let sprite = valvola as? SKShapeNode else { return }
                sprite.strokeColor = .white
            }
        }
        
        self.genericAgent.ioSelectionChanged = { io, newState in
            if newState == true {
//                guard let sprite = io as? SKShapeNode else { return }
                io.strokeColor = .blue
            } else {
//                guard let sprite = io as? SKShapeNode else { return }
                io.strokeColor = .white
            }
        }
        
        NotificationCenter.default.addObserver(forName: .sceneModeChanged, object: nil, queue: .main) { (notif) in
            guard let mode = notif.object as? Mode else { return }
            self.mode = mode
            print("mode changed in: \(mode)")
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {

        switch mode {
        case .editing:
            if valvoleLayoutChanged {
                lines.forEach { drawLine(line: $0) }
                valvoleLayoutChanged = false
            }
        case .running:

            lines.forEach { drawLine(line: $0) }
            valvoleLayoutChanged = false
            lines.forEach { $0.update() }
            
            let listeners = self.runtime.observables.filter { $0.isActive }
            listeners.forEach { $0.object.updateAction() }

        case .stopped: break
        }
        
    }

    // MARK: - Touches
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let nodes = self.nodes(at: touch.location(in: self))
        guard let node = nodes.first else { return }
        guard let valvola = node as? UIValvola else { return }
        print("Selected valvola")
        
        if genericAgent.hasToSelectMovableObjects == false {
            self.genericAgent.selectedValvola = valvola
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if genericAgent.isDragging {
            self.genericAgent.selectedValvola = nil
            print("Deselcted valvola after dragging")
        }
        
        genericAgent.isDragging = false
        
        guard let touch = touches.first else { return }
        let touchPosition = touch.location(in: self)
        let nodes = self.nodes(at: touchPosition)
        guard let node = nodes.first else { resetTouches(); return }
        
        if genericAgent.hasToSelectMovableObjects {
            guard let selectedValvola = node as? UIValvola else { return }
            guard let selectedMovableObject = selectedValvola.valvolaModel as? MovableObject else { return }
            
            guard let listener = genericAgent.selectedListenerObject else { return }
            if let movableObjectAttuale = listener.get(variable: .movableObject).getTypedValue(MovableObject.self) {
                self.runtime.removeObserving(object: movableObjectAttuale, from: listener)
            }

            self.runtime.observe(object: selectedMovableObject, observingObject: listener)
            
            listener.set(value: .movableObject(selectedMovableObject), toKey: VariablesKeys.movableObject)
            
            genericAgent.hasToSelectMovableObjects.toggle()
            return
        }
        
        
        if let objectIO = node as? GraphicalIO {
            handleTouchedIO(objectIO)
        } else if let pressableIO = node as? GraphicalPressableIO {
            pressableIO.modelIO.tap()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.genericAgent!.selectedValvola != nil {
            self.genericAgent.isDragging = true
            for touch in touches {
                let touchPoint = touch.location(in: self)
                self.genericAgent.selectedValvola!.position.x = touchPoint.x - 100
                self.genericAgent.selectedValvola!.position.y = touchPoint.y - 50
            }
        } else {
             guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            camera?.position.x -= location.x - previousLocation.x
            camera?.position.y -= location.y - previousLocation.y
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
        }
//        else {
//            if editinMode.state == .active {
//                editinMode.reset()
//                self.backgroundColor = self.defaultBackground
//            } else {
//                showTableView()
//            }
//        }
    }
    
    // MARK: - Generic Functions
    
    func handleTouchedIO(_ io: GraphicalIO) {
        select(io: io)
        
        if let firstIO = genericAgent.firstSelectedIO, let secondIO = genericAgent.secondSelectedIO {
            if firstIO.modelIO.isConnected(to: secondIO.modelIO) {
                self.runtime.disconnect(firstIO: firstIO.modelIO, from: secondIO.modelIO)
                let line = self.lines.first {
                    $0.firstIO == firstIO && $0.secondIO == secondIO || $0.firstIO == secondIO && $0.secondIO == firstIO
                }
                if let line = line {
                    self.remove(line: line)
                    self.resetTouches()
                }
            } else {
                self.runtime.connect(firstIO: firstIO.modelIO, with: secondIO.modelIO)
                self.createLine(from: firstIO, to: secondIO)
                self.resetTouches()
            }
            
        }
    }
    
    func select(io: GraphicalIO) {
        if genericAgent.firstSelectedIO == nil {
            genericAgent.firstSelectedIO = io
        } else if genericAgent.secondSelectedIO == nil {
            genericAgent.secondSelectedIO = io
            return
        } else {
            genericAgent.firstSelectedIO = io
            genericAgent.secondSelectedIO = nil
        }
    }
    
    fileprivate func makeExplosion(_ valvola: ValvolaConformance) {
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            let defaultVector = explosion.particlePositionRange
            let width = valvola.frame.width
            
            explosion.particlePositionRange = CGVector(dx: width, dy: defaultVector.dy)
            explosion.zPosition = 1
            explosion.position.x = valvola.position.x + valvola.frame.width / 2
            explosion.position.y = valvola.position.y - valvola.frame.height / 2
            addChild(explosion)
            
            let removeAction = SKAction.removeFromParent()
            let waitAction = SKAction.wait(forDuration: 1.5)
            let fullAction = SKAction.sequence([waitAction, removeAction])
            explosion.run(fullAction)
            valvola.run(fullAction)
        }
    }
    
    
    func resetTouches() {
        self.genericAgent.selectedValvola = nil
        genericAgent.firstSelectedIO = nil
        genericAgent.secondSelectedIO = nil
        
        for line in self.lines {
            line.strokeColor = .red
        }
    }
    
    
    
    func drawLine(line: Line) {
        let path = CGMutablePath()
        
        var startPoint = line.firstIO!.position
        var finishPoint = line.secondIO!.position
        
        startPoint.x += (line.firstIO.frame.width / 2)
        startPoint.y += (line.firstIO.frame.height / 2)
        
        finishPoint.x += (line.secondIO.frame.width / 2)
        finishPoint.y += (line.secondIO.frame.height / 2)
        
        let startPosition = convert(startPoint, from: line.firstIO!.parent!)
        let finishPosition = convert(finishPoint, from: line.secondIO!.parent!)
        
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
    
    func createLine(from firstIO: GraphicalIO, to secondIO: GraphicalIO) {
        let line = Line()
        line.firstIO = firstIO
        line.secondIO = secondIO
        
        drawLine(line: line)
        self.lines.append(line)
        addChild(line)
        
    }
    
    func removeLine(from firstIO: InputOutput, to secondIO: InputOutput) {
        let line = lines.first { (line) -> Bool in
            if line.firstIO == firstIO && line.secondIO == secondIO {
                return true
            } else if line.firstIO == secondIO && line.secondIO == firstIO {
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
    
    func remove(line: Line) {
        self.lines.removeAll(where: { $0 == line })
        
        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        let removeAction = SKAction.removeFromParent()
        
        let compoundAction = SKAction.sequence([fadeAction, removeAction])
        line.run(compoundAction)
    }
    
    func present(valvola: UIValvola, position: CGPoint? = nil) {
        if position == nil {
            let tempPoistion = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            let newPosition = convertPoint(fromView: tempPoistion)
            valvola.position = newPosition
            self.addChild(valvola)
        } else {
            var newPosition = convertPoint(fromView: position!)
            newPosition = convert(newPosition, to: self)
//            let newPosition = convert(position!, to: self)
//            let newPosition = convertPoint(toView: position!)
            valvola.position = newPosition
            self.addChild(valvola)
        }
    }
    
}
