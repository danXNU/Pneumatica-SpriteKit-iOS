//
//  Protocols.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

struct MovingPath {
    var startPoint: CGFloat
    var endPoint: CGFloat
}

protocol ValvolaConformance where Self: SKShapeNode {
    var id: UUID { get }
    var nome: String { get set }
    var descrizione: String { get set }
    
    var labelText: String { get }
    var ios : Set<InputOutput> { get }
    
    static var keyStringClass: String { get }
    static var preferredSize: CGSize { get }
    
    init(size: CGSize)
    
    func update()
    func enable()
}
extension ValvolaConformance {
    static var keyStringClass: String {
        return String(describing: self)
    }
    
    static var preferredSize: CGSize {
        return CGSize(width: 150, height: 50)
    }
}


protocol Movable {
    var movingPointValue: CGFloat { get }
    var movingObjectCurrentLocation: CGFloat { get }
    var movingPath: MovingPath! { get set }
}
extension Movable {
    var movingPointValue : CGFloat {
        let startPoint = self.movingPath.startPoint //20
        let endPoint = self.movingPath.endPoint // 40
        let pathLenght = (endPoint - startPoint) // 20
        
        let currentPoint = self.movingObjectCurrentLocation // 25
        let pathPercorsa = currentPoint - startPoint // 5
        
        let state = pathPercorsa / pathLenght // 5 : 20 = x : 1
        return state
    }
}

protocol AcceptsMovableInput {}

protocol IOConformance {
    var id: UUID { get set }
    var parentValvola : ValvolaConformance? { get set }
    var idleColor : UIColor { get set }
    var ariaPressure : Double { get set }
    func update()
}
extension IOConformance {
    func update() {}
}

protocol Tappable: IOConformance {
    func tapped()
}
extension Tappable {
    func tapped() {}
}



