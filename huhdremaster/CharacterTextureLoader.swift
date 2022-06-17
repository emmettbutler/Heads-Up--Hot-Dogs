import SpriteKit

class CharacterTextureLoader {
    var characterTextures: [CharacterTextureMap] = [CharacterTextureMap]()
    
    init() {
        characterTextures.append(BusinessmanTextureMap())
    }
}

class CharacterTextureMap {
    var idleHeadFrames: [SKTexture] = [SKTexture]()
    var idleHotDogHeadFrames: [SKTexture] = [SKTexture]()
    var idleBodyFrames: [SKTexture] = [SKTexture]()
    var walkHeadFrames: [SKTexture] = [SKTexture]()
    var walkHotDogHeadFrames: [SKTexture] = [SKTexture]()
    var walkBodyFrames: [SKTexture] = [SKTexture]()
}

class BusinessmanTextureMap: CharacterTextureMap {
    override init() {
        super.init()
        
        idleHeadFrames.append(SKTexture(imageNamed: "BusinessHead_Idle_NoDog.png"))
        idleHotDogHeadFrames.append(SKTexture(imageNamed: "BusinessHead_Idle_Dog.png"))
        for idx in 1 ... 2 {
            idleBodyFrames.append(SKTexture(imageNamed: NSString(format:"BusinessMan_Idle_%d.png", idx) as String))
        }
        for idx in 1 ... 3 {
            walkHeadFrames.append(SKTexture(imageNamed: NSString(format:"BusinessHead_NoDog_%d.png", idx) as String))
            walkHotDogHeadFrames.append(SKTexture(imageNamed: NSString(format:"BusinessHead_Dog_%d.png", idx) as String))
        }
        for idx in 1 ... 6 {
            walkBodyFrames.append(SKTexture(imageNamed: NSString(format:"BusinessMan_Walk_%d.png", idx) as String))
        }
    }
}
