import SpriteKit

class CharacterTextureLoader {
    var characterTextures: [CharacterTextureMap] = [CharacterTextureMap]()
    
    init() {
        characterTextures.append(BusinessmanTextureMap())
        characterTextures.append(YoungProfessionalTextureMap())
        characterTextures.append(JoggerTextureMap())
    }
    
    func getTextureMapBySlug(slug: String) -> CharacterTextureMap{
        for textureMap in characterTextures {
            if slug == textureMap.slug {
                return textureMap
            }
        }
        return characterTextures[0]
    }
}

class CharacterTextureMap {
    var slug: String = ""
    var idleHeadFrames: [SKTexture] = [SKTexture]()
    var idleHotDogHeadFrames: [SKTexture] = [SKTexture]()
    var idleBodyFrames: [SKTexture] = [SKTexture]()
    var walkHeadFrames: [SKTexture] = [SKTexture]()
    var walkHotDogHeadFrames: [SKTexture] = [SKTexture]()
    var walkBodyFrames: [SKTexture] = [SKTexture]()
    var headContactPointNotifyFrames: [SKTexture] = [SKTexture]()
    var heldHotDogsPointNotifyFrames: [SKTexture] = [SKTexture]()
    
    init() {
        for idx in 1 ... 13 {
            heldHotDogsPointNotifyFrames.append(SKTexture(imageNamed: NSString(format:"Plus_25_sm_%d.png", idx) as String))
        }
    }
}

class BusinessmanTextureMap: CharacterTextureMap {
    override init() {
        super.init()
        
        slug = Person.slugBusinessman
        
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
        for idx in 1 ... 11 {
            headContactPointNotifyFrames.append(SKTexture(imageNamed: NSString(format:"plusTen%d.png", idx) as String))
        }
    }
}

class YoungProfessionalTextureMap: CharacterTextureMap {
    override init() {
        super.init()
        
        slug = Person.slugYoungProfessional
        
        for idx in 1 ... 4 {
            walkHeadFrames.append(SKTexture(imageNamed: NSString(format:"YoungProfesh_Head_NoDog_%d.png", idx) as String))
            walkHotDogHeadFrames.append(SKTexture(imageNamed: NSString(format:"YoungProfesh_Head_Dog_%d.png", idx) as String))
        }
        for idx in 1 ... 8 {
            walkBodyFrames.append(SKTexture(imageNamed: NSString(format:"YoungProfesh_Walk_%d.png", idx) as String))
        }
        for idx in 1 ... 11 {
            headContactPointNotifyFrames.append(SKTexture(imageNamed: NSString(format:"PlusFifteen%d.png", idx) as String))
        }
    }
}

class JoggerTextureMap: CharacterTextureMap {
    override init() {
        super.init()
        
        slug = Person.slugJogger
        
        for idx in 1 ... 4 {
            walkHotDogHeadFrames.append(SKTexture(imageNamed: NSString(format:"Jogger_Head_Dog_%d.png", idx) as String))
        }
        for idx in 1 ... 8 {
            walkHeadFrames.append(SKTexture(imageNamed: NSString(format:"Jogger_Head_NoDog_%d.png", idx) as String))
            walkBodyFrames.append(SKTexture(imageNamed: NSString(format:"Jogger_Run_%d.png", idx) as String))
        }
        for idx in 1 ... 12 {
            headContactPointNotifyFrames.append(SKTexture(imageNamed: NSString(format:"plusTwentyFive%d.png", idx) as String))
        }
    }
}
