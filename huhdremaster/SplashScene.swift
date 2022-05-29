import SpriteKit
import GameplayKit

class SplashScene: SKScene {
    var startTime:Double = 0
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "Chicago_Thumb.png")
        addChild(background)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (self.startTime == 0) {
            self.startTime = currentTime
        }
        if (currentTime - self.startTime > 3) {
            let controller = self.view?.window?.rootViewController as! GameViewController
            controller.changeScene()
        }
    }
}
