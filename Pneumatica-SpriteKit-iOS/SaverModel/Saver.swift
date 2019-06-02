//
//  Saver.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 19/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class Saver {
    var virtualObjects : [Object] = []
    var nodes: [ValvolaConformance] = []
    
    var links: [Link] = []
    
    var circuit: Circuit
    var scene: SKScene
    
    init(circuitName: String, nodes: [ValvolaConformance], scene: SKScene, relativeObject: ValvolaConformance? = nil) {
        self.circuit = Circuit(name: circuitName)
        self.circuit.screenSize = scene.size
        self.scene = scene
        self.nodes = nodes
        calculate(objectRelative: relativeObject)
    }
    
    public func save(to fileName: String) throws {
        self.circuit.name = fileName
        self.circuit.allObjects = self.virtualObjects
        self.circuit.links = self.links
        
        let fileManager = FileManager.default
        do {
            let data = try JSONEncoder().encode(self.circuit)
            
            let filePath = Folders.documentsPath.appending("/\(fileName)")
            print("FILE PATH: \(filePath)")
            
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
            }
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        } catch {
            throw error
        }
    }
    
    
    private func calculate(objectRelative: ValvolaConformance? = nil) {
        for node in self.nodes {
            let name = node.name ?? ""
            guard let classType = ClassType.get(from: node) else { continue }
            
            var newObject = Object(name: name, classType: classType)
            newObject.id = node.id
            if let objParent = objectRelative {
                newObject.position = scene.convert(node.position, to: objParent)
//                newObject.position = node.convert(node.position, to: objParent)
            } else {
                newObject.position = node.position
            }
            
            newObject.zPosition = node.zPosition
            newObject.size = node.frame.size
            
            self.virtualObjects.append(newObject)
        }
    
        
        for node in self.nodes {
            let nodeIOs = node.ios
            
            for io in nodeIOs {
                guard let currentIO = self.createVirtualIO(from: io) else { continue }
                let connectedIOs = self.createMultipleVirtualIOs(from: io.inputsConnected)
                guard connectedIOs.count > 0 else { continue }
                
                let newLink = Link(currentIO: currentIO, connectedIOs: connectedIOs)
                self.links.append(newLink)
            }
            
        }
        
    }
    
    private func createVirtualIO(from io: InputOutput) -> IO? {
        guard let ioParentValvola = io.parentValvola else { return nil }
        guard let parentObject = self.virtualObjects.first(where: { $0.id == ioParentValvola.id }) else { return nil }
        
        return IO(ioID: io.id, objectIONumber: io.idNumber, objectID: parentObject.id)
    }
    
    private func createMultipleVirtualIOs(from collection: Set<InputOutput>) -> [IO] {
        var ios = [IO]()
        for nodeIo in collection {
            if let temp = self.createVirtualIO(from: nodeIo) {
                ios.append(temp)
            }
        }
        return ios
    }
    
}
