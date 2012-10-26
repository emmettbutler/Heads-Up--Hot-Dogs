Storing Level Data
==================

In classic Emmett form, the first time Diego mentioned the idea of multiple levels/areas
in Heads Up, my reaction was something between "how do you do that" and "that's
impossible". Claiming that problems are unsolvable is apparently a favorite pasttime
of mine, and at the time (around April), I could barely conceptualize the work necessary
to set up different levels. Of course, having done it, the problems now seem totally
trivial, but that's called learning I guess.

I was still a bit uncomfortable with Objective-C at that time, and a big question I
had was "how would we avoid massive code duplication across levels?". My gut reaction
to the idea was that all of the game logic code would at best be put into utility
functions, at worst be copy-pasted for each level*.

Luckily, I at least knew enough about good coding practices at the time to know that
both of the above were horrible ideas. Both were based on the idea that each level
would be contained in its own cocos2d screen, totally independent from the others.
This probably seemed like the most reasonable idea at the time.

I ended up slowly easing into a fully formed level implementation step by step. First,
we wanted to randomly choose a background image for the round: Philly or New York
(the only two backgrounds that were finished at the time). This seemed much less
intimidating than "building levels" to me, so this time my reaction was less fearful
and more pragmatic. Easy, just switch on a random number between 1 and 2 at game load
time to choose between two background images. We did something similar to choose audio
tracks for each round.

The real meat of the levels implementation came when I wanted to create a linking
between the background and the music - so that every time the NYC background was
shown, we'd hear the same music. This was solved simply enough by storing a struct
with the string name of the background and the string name of the audio file, one
struct for each level. Then, the random choice at load time was between two structs
instead of two strings. Much better than turning the whole game loop into shared
code (or copypasta).

Over time, ths struct grew to include lots of data about a specific level, until
it grew into what you see below (truncated for brevity)

.. code-block:: c

    +(NSValue *)chicago:(NSNumber *)full{
        BOOL loadFull = [full boolValue];

        // some properties are used only in-game, others are used on multiple screens
        // this saves load time on non-game screens

        levelProps *lp = new levelProps();
        lp->enabled = true;
        lp->slug = @"chicago";  // canonical identifier
        lp->name = @"Chicago";  // user-facing name
        lp->unlockNextThreshold = 8000;  // used for determining trophy level
        lp->thumbnail = @"Chicago_Thumb.png";  // level select screen image
        lp->func = @"switchScreenChicago";  // callback function to load level

        if(loadFull){
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites_chicago.plist"];
            lp->bg = @"Chicago_BG.png";  // gamplay background
            lp->bgm = @"04 - Chaos Dog In The Windy City.mp3";  // gamplay music
            lp->introAudio = @"03 - Chaos Dog In The Windy City (Intro).mp3";
            lp->gravity = -27.0f;  // force of gravity per level
            lp->spritesheet = @"sprites_chicago";
            lp->sfxVol = .8;
            lp->personSpeedMul = 1;  // multiplier for people's walk speed
            lp->restitutionMul = .8;  // multiplier for head bounciness
            lp->frictionMul = 1.1;  // multiplier for head friction
            lp->maxDogs = 6;  // initial value for max dogs allowed onscreen
            lp->hasShiba = true;  // is the dog in this level

            spcDogData *dd = new spcDogData();  // each level has a special sandwich
            dd->riseSprite = @"ChiDog_Rise.png";
            dd->fallSprite = @"ChiDog_Fall.png";
            dd->mainSprite = @"ChiDog.png";
            dd->grabSprite = @"ChiDog_Grab.png";
            // ...
            lp->spcDog = dd;
        }
        return [NSValue valueWithPointer:lp]];
    }

Looking back on this progression from naive implementation to sensible one, I notice
that the main difference between them is an attention to the actual form of the problem.
Turning the game loop into shared code between different level views might work in some
other cases, but for Heads Up it seems like overkill. A lot of code would still be
duplicated. Storing level data as structs, on the other hand, abstracts the idea of
a level out only as far as one level differs from another. All of the levels are
more or less the same. Hot dogs are always falling from the sky, sitting on the ground,
and then dying after some amount of time. All of the physics are the same. People
move in the same patterns. We don't need vastly different functions to deal with these.

The level structures encapsulate the exact ways that the levels differ from each other,
and nothing more. At load time, a struct is chosen from the array of all level structs
based on the ``slug`` field.

.. code-block:: c

        // populate an array with all of the level structs
        NSMutableArray *levelStructs = [LevelSelectLayer buildLevels:[NSNumber numberWithInt:1]];
        for(int i = 0; i < [levelStructs count]; i++){
            level = (levelProps *)[[levelStructs objectAtIndex:i] pointerValue];
            // if the slug is the one the levels screen passed in
            if(level->slug == levelSlug){
                // use it
                break;
            }
        }

*Looks like it might make more sense to pass in the whole struct here rather than
loading all of them and discarding all but one.*

The ``slug`` field of the level struct is also useful for storing persistent data
like high scores and unlocked levels. Cocoa allows apps to store a plist file full
of arbitrary keys and values persistently on the device, called ``NSUserDefaults``.
I think that's normally used to store the defaults for user-editable settings. I do
use it for that a bunch, like storing the sfx on/off preference, but I also use it
for the progression data mentioned above. The slug helps here since I can store a
key like

.. code-block:: c

        [standardUserDefaults setInteger:_score forKey:[NSString stringWithFormat:@"highScore%@", level->slug]];

persisting the high score for the current level. I do something similar for unlocked/not
unlocked and the highest trophy earned per level. I can read the stored data with

.. code-block:: c

        highScore = [standardUserDefaults integerForKey:[NSString stringWithFormat:@"highScore%@", level->slug]];

And just like that, we have persistent storage of per-level data.

Another clever and possibly questionable overloading of the ``slug`` functionality
is the way that the code chooses characters per level.

.. code-block:: c

    +(NSMutableArray *)philly{
        NSMutableArray *levelArray = [[[NSMutableArray alloc] init] retain];

        [levelArray addObject:[NSValue valueWithPointer:[self businessman]]];
        [levelArray addObject:[NSValue valueWithPointer:[self youngPro]]];
        [levelArray addObject:[NSValue valueWithPointer:[self jogger]]];

        return levelArray;
    }

Each level has a function associated with it, simply named the same as the level's slug.
Objective-C lets you call functions by string name pretty easily, which makes this
work awesomely. This function calls a few others, each of which load a specified
set of data encapsulating the differences between characters. Similar to the level
structs, these character structs only hold the data indicating the important ways
that the characters differ from each other - running speed, head bounciness, etc.

Each of the characters also has a "weight", which is used for probability weighting!
Some characters show up more often than others (eg the cop and the hipster guy are
rare). I might show that code in another post, but this one has enough code already.

So there's a whirlwind tour of the level-storing logic in Heads Up. There's a lot
of it, and aside from the game logic itself, this implementation probably took
the most effort out of any in the app.

*~emmett*

*\*Disclaimer: I realized how bad an idea this was long before I would have tried it.
Don't worry.*
