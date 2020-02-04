//
//  GameViewController.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 06/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var genericAgent: GenericAgent?
    
    var currentScene: SKScene!
    
    var sceneView: SKView = {
        let v = SKView(frame: .zero)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let cameraNode = SKCameraNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(sceneView)
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .resizeFill
            scene.genericAgent = genericAgent
            
            self.currentScene = scene
            
            scene.addChild(cameraNode)
            scene.camera = cameraNode
            
            // Present the scene
            sceneView.presentScene(scene)
        }
        
        sceneView.ignoresSiblingOrder = true
        
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
