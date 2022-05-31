import SpriteKit
import GameplayKit

class GameplayScene: BaseScene {
    var level: Level? = nil
    var lastHotDogSpawnTime: TimeInterval = 0
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(levelSlug: String) {
        self.init()
        self.level = levelWithSlug(levelSlug: levelSlug)
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: self.level!.background)
        background.xScale = UIScreen.main.bounds.width / background.size.width
        background.yScale = UIScreen.main.bounds.height / background.size.height
        addChild(background)
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
        if (self.startTime == 0) {
            self.startTime = currentTime
        }
        let secondsPassed: Double = round((currentTime - self.startTime) * 10) / 10.0
        if secondsPassed.truncatingRemainder(dividingBy: 2) == 0 {
            spawnHotDog(currentTime: currentTime)
        }
    }
    
    func spawnHotDog(currentTime: TimeInterval) {
        if (currentTime - lastHotDogSpawnTime < 1) {
            return
        }
        let hotDog: BaseSprite = BaseSprite(imageNamed: "dog54x12.png")
        hotDog.setRandomPosition()
        hotDog.setScene(scene: self)
        lastHotDogSpawnTime = currentTime
    }
}
