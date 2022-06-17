import SpriteKit
import GameplayKit

class GameplayScene: BaseScene, SKPhysicsContactDelegate {
    var level: Level? = nil
    var lastHotDogSpawnTime: TimeInterval = 0
    var allHotDogs: [HotDog] = [HotDog]()
    var allPeople: [Person] = [Person]()
    static let floorCategoryBitMasks: Array<UInt32> = [0b0001, 0b0010, 0b0011, 0b0100]
    static let wallCategoryBitMask: UInt32 = 0b1000
    static let droppedMax: Int = 5
    var hotDogsDropped: Int = 0
    var hotDogAppearFrames: [SKTexture] = [SKTexture]()
    var hotDogGroundDeathFrames: [SKTexture] = [SKTexture]()
    var helpDragFrames: [SKTexture] = [SKTexture]()
    var helpDropFrames: [SKTexture] = [SKTexture]()
    var headsUpDisplay: HeadsUpDisplay? = nil
    var highestFloor: SKShapeNode? = nil
    var timesAnyNogginWasTopped: Int = 0
    static let spriteZPositions: Dictionary = ["Person": 40.0, "HotDog": 50.0]
    var aHotDogIsGrabbed: Bool = false
    static let howManyInteractionsToHelpWith: Int = 2
    let characterTextureLoader: CharacterTextureLoader = CharacterTextureLoader()
    
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
        
        physicsWorld.contactDelegate = self
        
        spawnBoundaries()
        buildTextures()
        allPeople.append(Person(scene: self, textureLoader: characterTextureLoader))
        
        self.headsUpDisplay = HeadsUpDisplay(scene: self)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeB.physicsBody?.categoryBitMask == HotDog.categoryBitMask {
            let collidingHotDog: HotDog = nodeB as! HotDog
        
            if (GameplayScene.floorCategoryBitMasks.contains(nodeA.physicsBody!.categoryBitMask)){
                collidingHotDog.contactedFloor(currentTime: secondsPassed)
                
            } else if (nodeA.physicsBody!.categoryBitMask == Person.categoryBitMask) {
                let collidingHead: SKShapeNode = nodeA as! SKShapeNode
                if !collidingHotDog.nogginsTouched.contains(collidingHead) {
                    timesAnyNogginWasTopped += 1
                }
                
                collidingHotDog.contactedPerson(currentTime: secondsPassed, contactedNode: collidingHead)
                (nodeA.userData!["person"] as! Person).contactedHotDog(currentTime: secondsPassed)
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        for hotDog in allHotDogs {
            if !aHotDogIsGrabbed && hotDog.contains(pos){
                hotDog.grab(currentTime: secondsPassed)
                aHotDogIsGrabbed = true
            }
        }
        if aHotDogIsGrabbed {
            for person in allPeople {
                person.showHelpIndicator()
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        for hotDog in allHotDogs {
            hotDog.drag(toPos: pos)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        for hotDog in allHotDogs {
            if hotDog.contains(pos) {
                hotDog.releaseGrab()
            }
        }
        for person in allPeople {
            person.hideHelpIndicator()
        }
        aHotDogIsGrabbed = false
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
        secondsPassed = round((currentTime - self.startTime) * 10) / 10.0
        if secondsPassed.truncatingRemainder(dividingBy: 2) == 0 {
            spawnHotDog(currentTime: currentTime)
        }
        
        for child in self.children {
            if child is BaseSprite && (child as! BaseSprite).shouldBeDespawned {
                child.removeFromParent()
                if child is HotDog {
                    self.despawnHotDog(hotDog: child as! HotDog)
                }
            }
        }
        
        for hotDog in allHotDogs {
            hotDog.update(currentTime: secondsPassed)
        }
        
        for person in allPeople {
            person.update(currentTime: secondsPassed)
        }
    }
    
    func despawnHotDog(hotDog: HotDog) {
        hotDog.cleanup()
        allHotDogs.remove(at: allHotDogs.firstIndex(of: hotDog)!)
        hotDogsDropped += 1
        self.headsUpDisplay!.subtract()
        if hotDogsDropped >= GameplayScene.droppedMax {
            let controller = self.view?.window?.rootViewController as! GameViewController
            controller.changeScene(key: nil)
        }
    }
    
    func spawnHotDog(currentTime: TimeInterval) {
        if (currentTime - lastHotDogSpawnTime < 0.3) {
            return
        }
        allHotDogs.append(HotDog(scene: self))
        lastHotDogSpawnTime = currentTime
    }
    
    func buildTextures() {
        for idx in 1 ... 10 {
            hotDogAppearFrames.append(SKTexture(imageNamed: NSString(format:"Dog_Appear_%d.png", idx) as String))
        }
        for idx in 1 ... 7 {
            hotDogGroundDeathFrames.append(SKTexture(imageNamed: NSString(format:"Dog_Die_%d.png", idx) as String))
        }
        for idx in 1 ... 12 {
            helpDragFrames.append(SKTexture(imageNamed: NSString(format:"Drag_Overlay_%d.png", idx) as String))
            helpDropFrames.append(SKTexture(imageNamed: NSString(format:"Drop_Overlay_%d.png", idx) as String))
        }
    }
    
    func spawnBoundaries() {
        for index in GameplayScene.floorCategoryBitMasks {
            spawnFloor(index: index)
        }
        spawnWall(xPos: UIScreen.main.bounds.width / 2)
        spawnWall(xPos: UIScreen.main.bounds.width / -2)
    }
    
    func spawnFloor(index: UInt32) {
        let ground = SKShapeNode()
        let pathToDraw = CGMutablePath()
        let height: CGFloat = UIScreen.main.bounds.height / -2 + (65 - 15 * CGFloat(index))
        let startPoint = CGPoint(x: UIScreen.main.bounds.width / -2, y: height)
        ground.position = CGPoint(x: 0, y: startPoint.y)
        pathToDraw.move(to: CGPoint(x: startPoint.x, y: 0))
        pathToDraw.addLine(to: CGPoint(x: UIScreen.main.bounds.width / 2, y: 0))
        ground.physicsBody = SKPhysicsBody(edgeChainFrom: pathToDraw)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = index
        ground.physicsBody?.contactTestBitMask = HotDog.categoryBitMask
        addChild(ground)
        if highestFloor == nil || ground.position.y > (highestFloor?.position.y)! {
            highestFloor = ground
        }
    }
    
    func spawnWall(xPos: CGFloat) {
        let wall = SKShapeNode()
        let pathToDraw = CGMutablePath()
        let startPoint = CGPoint(x: xPos, y: UIScreen.main.bounds.height / 2)
        pathToDraw.move(to: startPoint)
        pathToDraw.addLine(to: CGPoint(x: startPoint.x, y: UIScreen.main.bounds.height / -2))
        wall.physicsBody = SKPhysicsBody(edgeChainFrom: pathToDraw)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = GameplayScene.wallCategoryBitMask
        addChild(wall)
    }
}
