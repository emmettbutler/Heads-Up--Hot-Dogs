//
//  GameScene.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/29/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var backgroundClouds: BackgroundClouds? = nil
    var scaleFactor: CGFloat = 1
    let dogLogo: SKSpriteNode = SKSpriteNode(imageNamed: "HotDogs.png")
    let swooshLogo: SKSpriteNode = SKSpriteNode(imageNamed: "HeadsUp.png")
    let startButton: SKSpriteNode = SKSpriteNode(imageNamed: "MenuItems_BG.png")
    let startText: SKLabelNode = SKLabelNode(text: "Start")
    
    override func didMove(to view: SKView) {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            scaleFactor = 2
        }
        let background = SKSpriteNode(imageNamed: "Splash_BG_clean.png")
        background.xScale = UIScreen.main.bounds.width / background.size.width
        background.yScale = UIScreen.main.bounds.height / background.size.height
        addChild(background)
        
        backgroundClouds = BackgroundClouds(scene:self)
        
        dogLogo.xScale = scaleFactor
        dogLogo.yScale = scaleFactor
        dogLogo.zPosition = 20
        dogLogo.position = CGPoint(x:0, y:UIScreen.main.bounds.height)
        let flyDogIn: SKAction = SKAction.move(to: CGPoint(x:0, y:0), duration: 0.6)
        flyDogIn.timingMode = SKActionTimingMode.easeOut
        dogLogo.run(flyDogIn, withKey: "fly")
        addChild(dogLogo)
        
        swooshLogo.xScale = scaleFactor
        swooshLogo.yScale = scaleFactor
        swooshLogo.zPosition = 20
        swooshLogo.position = CGPoint(x:-1 * UIScreen.main.bounds.width - swooshLogo.calculateAccumulatedFrame().width,
                                      y:dogLogo.calculateAccumulatedFrame().height / 2 + swooshLogo.calculateAccumulatedFrame().height / 2 + 20)
        swooshLogo.run(SKAction.move(to: CGPoint(x:-50, y:swooshLogo.position.y), duration: 0.4))
        addChild(swooshLogo)
        
        startButton.xScale = scaleFactor
        startButton.yScale = scaleFactor
        startButton.zPosition = 21
        startButton.position = CGPoint(x:0, y:dogLogo.calculateAccumulatedFrame().height / -2 - 70 * scaleFactor)
        addChild(startButton)
        startText.position = CGPoint(x:startButton.position.x, y:startButton.position.y - 8 * scaleFactor)
        startText.zPosition = 22
        startText.fontName = "M46_LOSTPET"
        startText.fontSize = 22 * scaleFactor
        startText.fontColor = UIColor(red: 255/255, green: 62/255, blue: 166/255, alpha: 1)
        addChild(startText)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (dogLogo.action(forKey: "fly") == nil) {
            dogLogo.position = CGPoint(x:dogLogo.position.x, y:(10 * CGFloat(sinf(Float(currentTime)))));
        }
    }
}
