//
//  Loader.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 19/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

enum LoaderError: Error {
    case errorFileData(String)
}

class Loader {
    private var circuit: Circuit
    
    private var allNodes : [ValvolaConformance] = []
    
    private var scene: SKScene!
    
    init(fileName: String, scene: SKScene) throws {
        self.scene = scene
        
        let fileManager = FileManager.default
        let path = Folders.documentsPath.appending("/\(fileName)")
        guard let data = fileManager.contents(atPath: path) else {
            throw LoaderError.errorFileData("Errore file data")
        }
        do {
            let circuit = try JSONDecoder().decode(Circuit.self, from: data)
            self.circuit = circuit
        } catch {
            throw error
        }
        
    }
    
//    public func load() {
//        for object in circuit.allObjects {
//            let newObject = object.classType.getNode(with: object.size)
//            newObject.id = object.id //SUPER IMPORTANT
//            newObject.name = object.name
//            newObject.position = object.position
//            newObject.zPosition = object.zPosition
//            allNodes.append(newObject)
//
//            (scene as! GameScene).valvole.append(newObject)
//            scene.addChild(newObject)
//        }
//
//        for link in circuit.links {
//            let io = link.currentIO
//            guard let nodeIO = self.getIONode(from: io) else { continue }
//
//            for ioConnected in link.connectedIOs {
//                guard let newNodeIO = getIONode(from: ioConnected) else { continue }
//                nodeIO.addWire(from: newNodeIO)
//
//                guard let gameScene = scene as? GameScene else { continue }
//                if !gameScene.lines.contains(where: { (line) -> Bool in
//                    line.firstIO == nodeIO && line.secondIO == newNodeIO ||
//                    line.firstIO == newNodeIO && line.secondIO == nodeIO
//                }) {
////                    gameScene.createLine(from: nodeIO, to: newNodeIO)
//                }
//            }
//        }
//
//    }
    
    private func getIONode(from io: IO) -> InputOutput? {
        let objectID = io.objectID
        guard let objectNode = self.getObjectNode(from: objectID) else { return nil }
        return objectNode.ios.first(where: { $0.idNumber == io.objectIONumber })
    }
    
    private func getObjectNode(from id: UUID) -> ValvolaConformance? {
        return self.allNodes.first(where: { $0.id == id })
    }
    
}
