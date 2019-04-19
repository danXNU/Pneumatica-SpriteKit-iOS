//
//  DiskObjects.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 19/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import Foundation
import CoreGraphics

struct Circuit : Codable {
    var id: UUID
    var version : String = "0.1"
    var name: String
    var screenSize: CGSize
    var allObjects: [Object]
    var links: [Link]
    
    init(name: String) {
        self.name = name
        self.id = UUID()
        self.screenSize = .zero
        self.allObjects = []
        self.links = []
    }
}

struct Object : Codable {
    var id: UUID
    var classType : ClassType
    var name: String
    var position: CGPoint
    var zPosition: CGFloat
    var size: CGSize
    
    init(name: String, classType: ClassType) {
        self.id = UUID()
        self.name = name
        self.classType = classType
        self.position = .zero
        self.zPosition = 0
        self.size = .zero
    }
}

struct IO : Codable {
    var id: UUID
    var objectIONumber: Int
    var name: String?
    var objectID: UUID
    
    init(ioID: UUID, objectIONumber: Int, objectID: UUID) {
        self.id = ioID
        self.objectIONumber = objectIONumber
        self.objectID = objectID
    }
}

struct Link : Codable {
    var currentIO : IO
    var connectedIOs : [IO]
}


enum ClassType : Int, Codable {
    case And = 1
    case Or = 2
    case Frl = 3
    case CilindroDE = 4
    case TreDueMS = 5
    case Timer = 6
    case CinqueDueBS = 7
    case pulsante = 8
    case finecorsa = 9
    case CinqueDueMS = 10
    case TreDueBS = 11
    
    static func get(from obj: ValvolaConformance) -> ClassType? {
        if obj is ValvolaAnd {
            return .And
        } else if obj is ValvolaOR {
            return .Or
        } else if obj is GruppoFRL {
            return .Frl
        } else if obj is CilindroDoppioEffetto {
            return .CilindroDE
        } else if obj is TreDueMonostabileNC {
            return .TreDueMS
        } else if obj is SpriteTimer {
            return .Timer
        } else if obj is CinqueDueBistabile {
            return .CinqueDueBS
        } else if obj is Pulsante {
            return .pulsante
        } else if obj is Finecorsa {
            return .finecorsa
        } else if obj is CinqueDueMonostabile {
            return .CinqueDueMS
        } else if obj is TreDueBistabile {
            return .TreDueBS
        } else {
            return nil
        }
    }
    
    func getNode(with size: CGSize) -> ValvolaConformance {
        switch self {
        case .And:
            return ValvolaAnd(size: size)
        case .CilindroDE:
            return CilindroDoppioEffetto(size: size)
        case .CinqueDueBS:
            return CinqueDueBistabile(size: size)
        case .CinqueDueMS:
            return CinqueDueMonostabile(size: size)
        case .finecorsa:
            return Finecorsa(size: size)
        case .Frl:
            return GruppoFRL(size: size)
        case .Or:
            return ValvolaOR(size: size)
        case .pulsante:
            return Pulsante(size: size)
        case .Timer:
            return SpriteTimer(size: size)
        case .TreDueBS:
            return TreDueBistabile(size: size)
        case .TreDueMS:
            return TreDueMonostabileNC(size: size)
        }
    }
}
