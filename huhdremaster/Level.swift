class Level {
    var enabled: Bool = true
    var slug: String = ""
    var name: String = ""
    var unlockNextThreshold: Int = 0
    var thumbnail: String = ""
    var background: String = ""
    var backgroundMusic: String = ""
    var personSpeedMultiplier: Float = 1
    var maxDogs: Int = 999
}

class Philly: Level {
    override init() {
        super.init()
        
        enabled = true
        slug = "philly"
        name = "Philly"
        unlockNextThreshold = 5000
        thumbnail = "Philly_Thumb.png"
        background = "bg_philly.png"
        backgroundMusic = "gameplay 1.mp3"
    }
}

class NewYork: Level {
    override init() {
        super.init()
        
        enabled = true
        slug = "nyc"
        name = "Big Apple"
        unlockNextThreshold = 7000
        thumbnail = "NYC_Thumb.png"
        background = "BG_NYC.png"
        backgroundMusic = "02 - Dances With Weenies.mp3"
        personSpeedMultiplier = 0.8
        maxDogs = 6
    }
}
