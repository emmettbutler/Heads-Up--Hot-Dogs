import SpriteKit
import GameplayKit

class SplashScene: SKScene {
    var startTime:Double = 0
    var phase:Int = 0
    let logoBackground: SKSpriteNode = SKSpriteNode(imageNamed: "Logo_Cloud.png")
    var backgroundClouds: BackgroundClouds? = nil
    let mainLogo: SKSpriteNode = SKSpriteNode(imageNamed: "ASg_Logo.png")
    let logoAnchor: CGPoint = CGPoint(x: 10, y: -20)
    let fadeOut: SKAction = SKAction.fadeOut(withDuration: 1)
    let fadeIn: SKAction = SKAction.fadeIn(withDuration: 1)
    let namesBackground: SKSpriteNode = SKSpriteNode(imageNamed: "CreatedBy_Cloud.png")
    let namesSprite: SKSpriteNode = SKSpriteNode(imageNamed: "CreatedBy_Names.png")
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x:0.5, y:0.5)
        let displaySize: CGRect = UIScreen.main.bounds
        
        let background = SKSpriteNode(imageNamed: "Splash_BG_clean.png")
        background.xScale = displaySize.width / background.size.width
        background.yScale = displaySize.height / background.size.height
        background.zPosition = 0
        addChild(background)
        
        backgroundClouds = BackgroundClouds(scene:self)
        
        logoBackground.zPosition = 20
        addChild(logoBackground)
        
        mainLogo.zPosition = 21
        addChild(mainLogo)
        
        namesBackground.alpha = 0
        namesBackground.zPosition = 20
        addChild(namesBackground)
        
        namesSprite.alpha = 0
        namesSprite.zPosition = 21
        addChild(namesSprite)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (self.startTime == 0) {
            self.startTime = currentTime
        }
        
        logoBackground.position = CGPoint(x:CGFloat(5 * sinf(Float(currentTime))),
                                          y:0)
        mainLogo.position = CGPoint(x:logoAnchor.x + CGFloat(6 * sinf(Float(currentTime * 1.5))),
                                    y:logoAnchor.y + CGFloat(3 * cosf(Float(currentTime))))
        namesSprite.position = CGPoint(x:CGFloat(5 * sinf(Float(currentTime))),
                                       y:0)
        
        if (phase == 0 && round((currentTime - self.startTime) * 10) / 10.0 == 1.5) {
            phase = 1
            logoBackground.run(fadeOut)
            mainLogo.run(fadeOut)
            namesBackground.run(fadeIn)
            namesSprite.run(fadeIn)
        }
        
        if (currentTime - self.startTime > 3) {
            let controller = self.view?.window?.rootViewController as! GameViewController
            //controller.changeScene()
        }
    }
}
