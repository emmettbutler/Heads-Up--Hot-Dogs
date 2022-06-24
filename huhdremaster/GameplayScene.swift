import SpriteKit
import GameplayKit

class GameplayScene: BaseScene, SKPhysicsContactDelegate {
    var level: Level? = nil
    var lastHotDogSpawnTime: TimeInterval = 0
    var lastPersonSpawnTime: TimeInterval = 0
    var allHotDogs: [HotDog] = [HotDog]()
    var allPeople: [Person] = [Person]()
    static let floorCategoryBitMasks: Array<UInt32> = [0b0001, 0b0010, 0b0100, 0b1000]
    static let wallCategoryBitMask: UInt32 = 0b10000
    static let droppedMax: Int = 5
    var hotDogsDropped: Int = 0
    var hotDogAppearFrames: [SKTexture] = [SKTexture]()
    var hotDogGroundDeathFrames: [SKTexture] = [SKTexture]()
    var helpDragFrames: [SKTexture] = [SKTexture]()
    var helpDropFrames: [SKTexture] = [SKTexture]()
    var headsUpDisplay: HeadsUpDisplay? = nil
    var pointCounter: PointCounter? = nil
    var highestFloor: SKShapeNode? = nil
    var timesAnyNogginWasTopped: Int = 0
    static let spriteZPositions: Dictionary = ["Person": 40.0, "HotDog": 50.0, "Notification": 60.0]
    var aHotDogIsGrabbed: Bool = false
    static let howManyInteractionsToHelpWith: Int = 2
    let characterTextureLoader: CharacterTextureLoader = CharacterTextureLoader()
    static let pointsForHeadContact: Int = 50
    static let pointsForHotDogStayedOnHead: Int = 25
    
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
        
        self.headsUpDisplay = HeadsUpDisplay(scene: self)
        self.pointCounter = PointCounter(scene: self)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        var collidingHotDog: HotDog? = nil
        var collidingOtherObject: SKNode? = nil
        if nodeA.physicsBody?.categoryBitMask == HotDog.categoryBitMask {
            collidingHotDog = nodeA as! HotDog
            collidingOtherObject = nodeB
        } else if nodeB.physicsBody?.categoryBitMask == HotDog.categoryBitMask {
            collidingHotDog = nodeB as! HotDog
            collidingOtherObject = nodeA
        }
        if collidingHotDog == nil {
            return
        }
 
        handleContact(collidingHotDog: collidingHotDog!, collidingOtherObject: collidingOtherObject!)
    }
    
    func handleContact(collidingHotDog: HotDog, collidingOtherObject: SKNode) {
        if (GameplayScene.floorCategoryBitMasks.contains(collidingOtherObject.physicsBody!.categoryBitMask)){
            collidingHotDog.contactedFloor(currentTime: secondsPassed)
        } else if (collidingOtherObject.physicsBody!.categoryBitMask == Person.categoryBitMask) {
            handleHotDogHeadContact(collidingHotDog: collidingHotDog,
                                    collidingHead: collidingOtherObject as! SKShapeNode,
                                    collidingPerson: collidingOtherObject.userData!["person"] as! Person)
        }
    }
    
    func handleHotDogHeadContact(collidingHotDog: HotDog, collidingHead: SKShapeNode, collidingPerson: Person) {
        if !collidingHotDog.nogginsTouchedSinceLastGrab.contains(collidingHead) {
            timesAnyNogginWasTopped += 1
            pointCounter?.points += GameplayScene.pointsForHeadContact
        }
        
        collidingHotDog.contactedPerson(currentTime: secondsPassed, contactedNode: collidingHead)
        collidingPerson.contactedHotDog(currentTime: secondsPassed, hotDog: collidingHotDog)
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
        spawnPerson(currentTime: currentTime)
        
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
            if person.shouldBeDespawned {
                despawnPerson(person: person)
            }
        }
        
        self.pointCounter!.update(currentTime: currentTime)
    }
    
    func despawnHotDog(hotDog: HotDog) {
        hotDog.cleanup()
        allHotDogs.remove(at: allHotDogs.firstIndex(of: hotDog)!)
        hotDogsDropped += 1
        self.headsUpDisplay!.subtract()
        if hotDogsDropped >= GameplayScene.droppedMax {
            let controller = self.view?.window?.rootViewController as! GameViewController
            //controller.changeScene(key: nil)
        }
    }
    
    func despawnPerson(person: Person) {
        person.cleanup()
        allPeople.remove(at: allPeople.firstIndex(of: person)!)
    }
    
    func spawnHotDog(currentTime: TimeInterval) {
        if (currentTime - lastHotDogSpawnTime < 0.3) {
            return
        }
        let hotDog: HotDog = HotDog(scene: self)
        allHotDogs.append(hotDog)
        //let headToSpawnAbove: Person = allPeople.randomElement()!
        //hotDog.position = CGPoint(x:headToSpawnAbove.position.x + CGFloat(headToSpawnAbove.spawnXSign * -1 * 70), y: headToSpawnAbove.position.y + 50)
        lastHotDogSpawnTime = currentTime
    }
    
    func spawnPerson(currentTime: TimeInterval) {
        if (currentTime - lastPersonSpawnTime < 4) {
            return
        }
        let choice: Int = Int.random(in: 1 ... 3)
        var person: Person? = nil;
        if choice == 1 {
            person = Businessman(scene: self, textureLoader: characterTextureLoader)
        } else if choice == 2 {
            person = YoungProfessional(scene: self, textureLoader: characterTextureLoader)
        } else if choice == 3 {
            person = Jogger(scene: self, textureLoader: characterTextureLoader)
        }
        allPeople.append(person!)
        lastPersonSpawnTime = currentTime
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
        for index in 0 ... GameplayScene.floorCategoryBitMasks.count - 1 {
            spawnFloor(index: index)
        }
        spawnWall(xPos: UIScreen.main.bounds.width / 2)
        spawnWall(xPos: UIScreen.main.bounds.width / -2)
    }
    
    func spawnFloor(index: Int) {
        let ground = SKShapeNode()
        let pathToDraw = CGMutablePath()
        let height: CGFloat = UIScreen.main.bounds.height / -2 + (55 - 15 * CGFloat(index))
        let startPoint = CGPoint(x: UIScreen.main.bounds.width / -2, y: height)
        ground.position = CGPoint(x: 0, y: startPoint.y)
        pathToDraw.move(to: CGPoint(x: startPoint.x, y: 0))
        pathToDraw.addLine(to: CGPoint(x: UIScreen.main.bounds.width / 2, y: 0))
        ground.path = pathToDraw
        ground.zPosition = 100
        ground.strokeColor = .blue
        ground.physicsBody = SKPhysicsBody(edgeChainFrom: pathToDraw)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = GameplayScene.floorCategoryBitMasks[index]
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
