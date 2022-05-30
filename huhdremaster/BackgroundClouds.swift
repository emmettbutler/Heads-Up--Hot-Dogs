import SpriteKit

class BackgroundClouds {
    let cloud1: BaseSprite = BaseSprite(imageNamed: "Cloud_1.png")
    let cloud2: BaseSprite = BaseSprite(imageNamed: "Cloud_3.png")
    let cloud3: BaseSprite = BaseSprite(imageNamed: "Cloud_2.png")
    
    init(scene:BaseScene) {
        cloud1.position = CGPoint(x:UIScreen.main.bounds.width / 2, y:0)
        cloud1.zPosition = 1
        cloud1.run(SKAction.move(to: CGPoint(x:0, y:cloud1.position.y), duration: 90))
        cloud1.setScene(scene: scene)
        
        cloud2.position = CGPoint(x:-1 * UIScreen.main.bounds.width / 2, y:UIScreen.main.bounds.height / 2 - 50 * scene.scaleFactor)
        cloud2.zPosition = 1
        cloud2.run(SKAction.move(to: CGPoint(x:UIScreen.main.bounds.width / 2, y:cloud2.position.y), duration: 80))
        cloud2.setScene(scene: scene)
        
        cloud3.position = CGPoint(x:-1 * UIScreen.main.bounds.width / 2,
                                  y:-1 * UIScreen.main.bounds.height / 2 + 50 * scene.scaleFactor)
        cloud3.zPosition = 1
        cloud3.run(SKAction.move(to: CGPoint(x:UIScreen.main.bounds.width / 2, y:cloud3.position.y), duration: 100))
        cloud3.setScene(scene: scene)
    }
}
