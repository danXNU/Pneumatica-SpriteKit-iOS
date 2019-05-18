//
//  MovableEditMode.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/05/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

struct EditingMode {
    enum State {
        case active
        case disabled
    }
    var state : State = .disabled
    var selectedInput : Movable? = nil
    var selectedValvolaWithMovableInput : AcceptsMovableInput? = nil
    var valueOfMovable : Float = 0.0
    var editView : EditView!
    
    private var sceneFrame: CGRect
    
    init(sceneFrame: CGRect) {
        self.sceneFrame = sceneFrame
        reset()
    }
    
    mutating func reset() {
        self.state = .disabled
        self.selectedInput = nil
        self.selectedValvolaWithMovableInput = nil
        self.valueOfMovable = 0.0
        self.editView?.removeFromSuperview()
        
        let height = 200
        let width = 300
        let x = Int(sceneFrame.width) / 2 - width / 2
        let y = Int(sceneFrame.height) / 2 - height / 2
        
        self.editView = EditView(frame: .init(x: x, y: y, width: width, height: height))
    }
}
