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
    @IBOutlet weak var modeSegment: UISegmentedControl!
    
    var genericAgent: GenericAgent?
    
    var currentScene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill
                scene.genericAgent = genericAgent
                
                self.currentScene = scene
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
    
    @IBAction func modeSegmentChanged(_ sender: UISegmentedControl) {
        var mode: Mode = .editing
        switch sender.selectedSegmentIndex {
        case 0: mode = .editing
        case 1: mode = .running
        default: break
        }
        NotificationCenter.default.post(name: .sceneModeChanged, object: mode)
    }
    
    @IBAction func saveTouched(_ sender: UIButton) {
        let command = CommandCode.save
        NotificationCenter.default.post(name: .commandSent, object: command)
    }
    
    @IBAction func save3DTouched(_ sender: UIButton) {
        let command = CommandCode.save3D
        NotificationCenter.default.post(name: .commandSent, object: command)
    }
    
    @IBAction func caricaTouched(_ sender: UIButton) {
        let command = CommandCode.load
        NotificationCenter.default.post(name: .commandSent, object: command)
    }
    
    @IBAction func cestinoTouched(_ sender: UIButton) {
        let command = CommandCode.trash
        NotificationCenter.default.post(name: .commandSent, object: command)
    }
    
    
    @IBAction func arButtonTapped(_ sender: UIButton) {
    }
    
}
