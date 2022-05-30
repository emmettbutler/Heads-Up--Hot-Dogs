//
//  GameViewController.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/29/22.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var currentScene:SKScene? = nil;

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            self.changeScene()
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func changeScene() {
        var scene:SKScene
        switch self.currentScene {
            case is SplashScene:
                scene = GameScene()
            default:
                scene = SplashScene()
        }
        
        scene.scaleMode = .resizeFill
        scene.anchorPoint = CGPoint(x:0.5, y:0.5)
        if let view = self.view as! SKView? {
            view.presentScene(scene)
        }
        self.currentScene = scene
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
