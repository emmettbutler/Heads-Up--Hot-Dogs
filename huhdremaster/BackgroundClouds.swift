import SpriteKit

class BackgroundClouds {
    let cloud1: SKSpriteNode = SKSpriteNode(imageNamed: "Cloud_1.png")
    let cloud2: SKSpriteNode = SKSpriteNode(imageNamed: "Cloud_3.png")
    let cloud3: SKSpriteNode = SKSpriteNode(imageNamed: "Cloud_2.png")
    var scaleFactor: CGFloat = 1
    
    init(scene:SKScene) {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            scaleFactor = 2.13
        }
        cloud1.position = CGPoint(x:UIScreen.main.bounds.width / 2, y:0)
        cloud1.zPosition = 1
        cloud1.xScale = scaleFactor
        cloud1.yScale = scaleFactor
        cloud1.run(SKAction.move(to: CGPoint(x:0, y:cloud1.position.y), duration: 90))
        scene.addChild(cloud1)
        
        cloud2.position = CGPoint(x:-1 * UIScreen.main.bounds.width / 2, y:UIScreen.main.bounds.height / 2 - 50 * scaleFactor)
        cloud2.zPosition = 1
        cloud2.xScale = scaleFactor
        cloud2.yScale = scaleFactor
        cloud2.run(SKAction.move(to: CGPoint(x:UIScreen.main.bounds.width / 2, y:cloud2.position.y), duration: 80))
        scene.addChild(cloud2)
        
        cloud3.position = CGPoint(x:-1 * UIScreen.main.bounds.width / 2, y:-1 * UIScreen.main.bounds.height / 2 + 50 * scaleFactor)
        cloud3.zPosition = 1
        cloud3.xScale = scaleFactor
        cloud3.yScale = scaleFactor
        cloud3.run(SKAction.move(to: CGPoint(x:UIScreen.main.bounds.width / 2, y:cloud3.position.y), duration: 100))
        scene.addChild(cloud3)
    }
}
