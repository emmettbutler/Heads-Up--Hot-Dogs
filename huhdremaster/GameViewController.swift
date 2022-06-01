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
            self.changeScene(key: nil)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func changeScene(key: String?) {
        var scene:SKScene = SplashScene()
        
        switch self.currentScene {
            case is SplashScene:
                scene = TitleScene()
            case is TitleScene:
                if key == "levels" {
                    scene = LevelSelectScene()
                } else if key == "options" {
                    scene = OptionsScene()
                }
            case is LevelSelectScene:
                if key == "title" {
                    scene = TitleScene()
                } else {
                    scene = GameplayScene(levelSlug: key!)
                }
            case is OptionsScene:
                scene = TitleScene()
            default:
                scene = GameplayScene(levelSlug: "philly")
        }
        
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
