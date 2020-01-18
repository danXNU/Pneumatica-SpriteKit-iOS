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
    
    var defaultBackground: UIColor!
    
    var firstSelectedIO: InputOutput?
    var secondSelectedIO: InputOutput?
    var lines: [Line] = []
    
    var holdRecognizer: UILongPressGestureRecognizer!
    var tableView : UITableView!
    var dataSource : UITableViewDataSource!
    
    var editinMode : EditingMode!
    
    var valvole: [ValvolaConformance] = []
    var selectedValvola : ValvolaConformance?
    var valvoleLayoutChanged: Bool = false
    
    var runtime: IPRuntime = IPRuntime(startingPoint: [])
    var newValvoleNodes: [ValvolaStateReceiver] = []
    
    let cameraNode = SKCameraNode()
    
    var newSelectedValvola: UIValvola?
    var newFirstSelectedIO: GraphicalIO?
    var newSecondSelectedIO: GraphicalIO?
    
    
    var isDragging: Bool = false
    
    //MARK: - Lifecycle
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        self.anchorPoint = .zero
        
        self.defaultBackground = self.backgroundColor
        
        self.editinMode = EditingMode(sceneFrame: self.frame)
        
        self.tableView = UITableView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(BoldCell.self, forCellReuseIdentifier: "BoldCell")
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        
        self.holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(holdPoint(_:)))
        self.view?.addGestureRecognizer(self.holdRecognizer)
        
        self.camera = cameraNode
        
        self.runtime.start()
        
        NotificationCenter.default.addObserver(forName: .sceneModeChanged, object: nil, queue: .main) { (notif) in
            guard let mode = notif.object as? Mode else { return }
            self.mode = mode
            print("mode changed in: \(mode)")
        }
        
//        NotificationCenter.default.addObserver(forName: .commandSent, object: nil, queue: .main) { (notif) in
//            guard let command = notif.object as? CommandCode else { return }
//            switch command {
//            case .trash:
//                if let valvola = self.selectedValvola {
//                    for line in self.lines {
//                        if valvola.ios.contains(line.firstIO) ||
//                            valvola.ios.contains(line.secondIO) {
//                            self.remove(line: line)
//                        }
//                    }
//                    self.makeExplosion(valvola)
//                    self.valvole.removeAll(where: { $0 == valvola })
//                    self.selectedValvola = nil
//                }
//
//            case .load:
//                do {
//                    let loader = try Loader(fileName: "circuit.json", scene: self.scene!)
//                    loader.load()
//                } catch {
//                    UIApplication.shared.keyWindow?.rootViewController?.showAlert(withTitle: "Errore", andMessage: "\(error)")
//                }
//            case .save:
//                let valvole = self.valvole
//                let saver = Saver(circuitName: "TestCircuitName", nodes: valvole, scene: self.scene!)
//                do {
//                    try saver.save(to: "circuit.json")
//                } catch {
//                    UIApplication.shared.keyWindow?.rootViewController?.showAlert(withTitle: "Errore", andMessage: "\(error)")
//                }
//            case .save3D:
//                guard let objectParent = self.selectedValvola else {
//                    UIApplication.shared.keyWindow?.rootViewController?.showAlert(withTitle: "Errore", andMessage: "Non hai selezionato la valvola da cui ottenere le varie posizioni relative ad essa")
//                    return
//                }
//                let saver = Saver(circuitName: "Circuit2Dto3D", nodes: self.valvole,
//                                  scene: self.scene!, relativeObject: objectParent)
//
//                do {
//                    try saver.save(to: "circuit2D-3D.json")
//                } catch {
//                    UIApplication.shared.keyWindow?.rootViewController?.showAlert(withTitle: "Errore", andMessage: "\(error)")
//                }
//            }
//        }
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
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touchPoint = touches.first?.location(in: self)
//
//        let nodes = self.nodes(at: touchPoint!)
//
//        if editinMode.state == .active {
//            if let movableObject = nodes.first as? Movable {
//                editinMode.selectedInput = movableObject
//            }
//            if editinMode.selectedInput != nil && editinMode.selectedValvolaWithMovableInput != nil {
//                editinMode.selectedValvolaWithMovableInput?.movableInput = editinMode.selectedInput
//                editinMode.selectedValvolaWithMovableInput?.listenValue = editinMode.editView.sliderValue
//                editinMode.reset()
//                self.backgroundColor = self.defaultBackground
//            }
//            return
//        }
//
//
//        if let tappableIO = nodes.first as? Tappable {
//            tappableIO.tapped()
//        } else if let clickedIO = nodes.first as? InputOutput {
//            if firstSelectedIO == nil { firstSelectedIO = clickedIO }
//            else if secondSelectedIO == nil { secondSelectedIO = clickedIO }
//
//            if let firstValvola = firstSelectedIO?.parentValvola, let secondValvola = secondSelectedIO?.parentValvola {
//                if firstValvola == secondValvola {
//                    print("Non puoi collegare un filo alla stessa valvola")
//                    resetTouches()
//                    return
//                }
//            }
//
//
//            if let firstIO = firstSelectedIO, let secondIO = secondSelectedIO {
//                if firstIO.inputsConnected.contains(secondIO) && secondIO.inputsConnected.contains(firstIO) {
//                    removeLine(from: firstIO, to: secondIO)
//                } else {
//                    createLine(from: firstIO, to: secondIO)
//                }
//                resetTouches()
//            }
//
//
//        } else if let valvola = nodes.first as? ValvolaConformance {
//            selectedValvola?.strokeColor = .white
//            selectedValvola = valvola
//            selectedValvola?.strokeColor = .blue
//
//            if mode != .running {
//                selectedValvola?.ios.forEach { $0.fillColor = .blue }
//                for line in self.lines {
//                    if selectedValvola?.ios.contains(line.firstIO) ?? false ||
//                        selectedValvola?.ios.contains(line.secondIO) ?? false {
//                        line.strokeColor = .blue
//                    } else {
//                        line.strokeColor = .red
//                    }
//                }
//            }
//        } else {
//            resetTouches()
//            hideTableView()
//        }
//    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let nodes = self.nodes(at: touch.location(in: self))
        guard let node = nodes.first else { return }
        guard let valvola = node as? UIValvola else { return }
        print("Selected valvola")
        
        newSelectedValvola = valvola
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDragging {
            newSelectedValvola = nil
            print("Deselcted valvola after dragging")
        }
        
        isDragging = false
        
        guard let touch = touches.first else { return }
        let touchPosition = touch.location(in: self)
        let nodes = self.nodes(at: touchPosition)
        guard let node = nodes.first else { return }
        
        if let objectIO = node as? GraphicalIO {
            handleTouchedIO(objectIO)
        } else if let pressableIO = node as? GraphicalPressableIO {
            pressableIO.modelIO.tap()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if newSelectedValvola != nil {
            self.isDragging = true
            for touch in touches {
                let touchPoint = touch.location(in: self)
                newSelectedValvola!.position.x = touchPoint.x - 100
                newSelectedValvola!.position.y = touchPoint.y - 50
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
        } else {
            if editinMode.state == .active {
                editinMode.reset()
                self.backgroundColor = self.defaultBackground
            } else {
                showTableView()
            }
        }
    }
    
    // MARK: - Generic Functions
    
    func handleTouchedIO(_ io: GraphicalIO) {
        select(io: io)
        
        if let firstIO = newFirstSelectedIO, let secondIO = newSecondSelectedIO {
            if firstIO.modelIO.isConnected(to: secondIO.modelIO) {
                self.runtime.disconnect(firstIO: firstIO.modelIO, from: secondIO.modelIO)
                let line = self.lines.first {
                    $0.firstIO == firstIO && $0.secondIO == secondIO || $0.firstIO == secondIO && $0.secondIO == firstIO
                }
                if let line = line {
                    self.remove(line: line)
                }
            } else {
                self.runtime.connect(firstIO: firstIO.modelIO, with: secondIO.modelIO)
                self.createLine(from: firstIO, to: secondIO)
            }
            
        }
    }
    
    func select(io: GraphicalIO) {
        if newFirstSelectedIO == nil {
            newFirstSelectedIO = io
        } else if newSecondSelectedIO == nil {
            newSecondSelectedIO = io
            return
        } else {
            newFirstSelectedIO = io
            newSecondSelectedIO = nil
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
        
        for valvola in self.valvole {
            for input in valvola.ios {
                input.fillColor = input.idleColor
            }
        }
        
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

extension GameScene : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        hideTableView()
        guard let dataSource = self.dataSource as? ObjectCreationDataSource else { return }
        
        let node = dataSource.createInstanceOf(type: ValvoleTypes.type(at: indexPath.row))
        
        self.newValvoleNodes.append(node)
        self.runtime.addInCircuit(valvola: node.valvolaModel, hasToInitialize: false)
        if let startingPoint = node as? DXPneumatic.GruppoFRL {
            self.runtime.addStartingPoint(startingPoint.valvolaModel)
        }
            
        if let observable = node as? DXPneumatic.ChangeListener {
            let listener = Listener(uiObject: observable, model: node.valvolaModel)
            self.runtime.observables.append(listener)
        }
        
        if let finecorsa = node as? DXPneumatic.Finecorsa {
            guard let object = self.runtime.valvole.first(where: { $0 is IPCilindroDE }) else { fatalError() }
            guard let cilindro = object as? IPCilindroDE else { fatalError() }
            guard let finecorsaModel = finecorsa.valvolaModel as? IPFinecorsa else { fatalError() }
            runtime.observe(object: cilindro, observingObject: finecorsaModel)
        }
        
        present(valvola: node)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
