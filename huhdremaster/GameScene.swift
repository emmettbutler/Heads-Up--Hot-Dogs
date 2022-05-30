//
//  GameScene.swift
//  huhdremaster
//
//  Created by Emmett Butler on 5/29/22.
//

import SpriteKit
import GameplayKit

class GameScene: BaseScene {
    var backgroundClouds: BackgroundClouds? = nil
    let dogLogo: BaseSprite = BaseSprite(imageNamed: "HotDogs.png")
    let swooshLogo: BaseSprite = BaseSprite(imageNamed: "HeadsUp.png")
    let startButton: TextButton = TextButton(text: "Start")
    
    override init() {
        super.init()
        for sprite in [dogLogo, swooshLogo] {
            sprite.setScene(scene: self)
        }
        startButton.setScene(scene: self)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "Splash_BG_clean.png")
        background.xScale = UIScreen.main.bounds.width / background.size.width
        background.yScale = UIScreen.main.bounds.height / background.size.height
        addChild(background)
        
        backgroundClouds = BackgroundClouds(scene:self)
        
        dogLogo.zPosition = 20
        dogLogo.position = CGPoint(x:0, y:UIScreen.main.bounds.height)
        let flyDogIn: SKAction = SKAction.move(to: CGPoint(x:0, y:0), duration: 0.6)
        flyDogIn.timingMode = SKActionTimingMode.easeOut
        dogLogo.run(flyDogIn, withKey: "fly")
        
        swooshLogo.zPosition = 20
        swooshLogo.position = CGPoint(x:-1 * UIScreen.main.bounds.width - swooshLogo.calculateAccumulatedFrame().width,
                                      y:dogLogo.calculateAccumulatedFrame().height / 2 + swooshLogo.calculateAccumulatedFrame().height / 2 + 20)
        swooshLogo.run(SKAction.move(to: CGPoint(x:-50, y:swooshLogo.position.y), duration: 0.4))
        
        startButton.setZ(zPosition: 21)
        startButton.setPosition(position: CGPoint(x:0, y:dogLogo.calculateAccumulatedFrame().height / -2 - 70 * scaleFactor))
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
