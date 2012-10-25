Touch Tracking
==============

Since Heads Up's core gameplay centers on the quick manipulation of physics objects
with touches, designing some system that allowed it efficiently and cleanly was
one of my biggest concerns during development.

We knew from the beginning that we wanted to allow players to grab hot dogs with
their fingers, and this basic interaction was something that I actually learned
on my first night working through some example box2d code. The general idea is simple:
when a touch event happens inside the boundaries of a grabbable object, create what
box2d calls a mouse joint, which is a type of physics joint specifically made for
mouse (or finger) manipulation. Use this joint to connect the finger and the object,
moving the object to the touch position for the duration of the touch, and destroying
the joint when the touch ends. Not so bad.

The big requirement that made this more of a problem was multitouch. When we had the
guarantee that only one hot dog would ever be grabbed at a time, it was easy to use
the simple algorithm above to move it along with the only touch. When there could be more
than one grabbed hot dog at a time, though, there was suddenly the issue of determining
which touch should have which hot dog attached to it.

My first try here was to use the above algorithm to try and handle more than one
touch, with predictably unsatisfying results. One touch still worked fine, but
touching anywhere else on the screen (grabbing a hot dog or not) caused the hot dog that
the first touch was holding to float halfway between the two touches, constantly
having its target position alternated between the two touch positions. The program
logic was telling the hot dog to be in both positions at once, instead of choosing
just one touch to hold it.

*Aside: I guess I probably had no idea why that was happening at the time, and I most likely
said something like "that's a showstopper bug". This seems a lot simpler in hindsight.*

So this was a problem. It seemed like a big problem. I was scared of it. And intrigued.

My naive approach was, essentially, an attempt to roll my own system of identifying
touches uniquely. "Why would he do that?" you might wonder, "Doesn't he know about
touch hashes?" Unfortunately the answer at the time was no. But more on that in a moment.

My best attempt to uniquely identify touch events was based on movement tracking -
intuitively: "if this touch is close to where touch A was a second ago, this touch
must be touch A". meh.

The touch's last known position was saved and compared to its current position, and I
treated them as part of the same "macro" touch event if the current and past positions
were close enough together. I was actually really happy with this implementation at the
time, thinking I was pretty smart for figuring out what (for some reason) I hadn't been
able to find on any box2d forum.

Predictably, though, there were a ton of problems. Worst, since the comparison between
positions involved testing an absolute value for proximity to zero, the bottom
right corner of the screen became a bug haven (in cocos, bottom-right is the origin).
The dog-grabbing logic sort of broke down near this area. Aside from that, the
design imposed a maximum speed for hot dog dragging, since touches that moved too
far per frame would leave their hot dogs behind. As a result, the core interaction
felt kind of sluggish. Sometimes hot dogs wouldn't respond to touches. Sometimes
they'd get stuck in midair. Bringing two dragged hot dogs close enough together made
them do strange things. Not good.

We lived with this system for a while, through the early testing phases. Testers
reported all of the bugs mentioned above (which I already knew about). Then one day,
for some reason, I decided to google something like "ios touch event identifier" and
discovered that iOS gives each complete touch event its own unique id for its
entire duration - that is, across touchesBegan, touchesMoved, and touchesCancelled -
the hash.

Suddenly the whole problem became practically trivial. Not having to worry about
providing touch ID myself, keeping hot dog grabs separate was as simple as comparing
new touch hashes against stored ones. The above intuition becomes "if this touch has
the same ID as touch A, then it is touch A". Much better. (Notice the difference in
wordings: "must be" versus "is")

Look at this code:

.. code-block:: c

    // in CCTouchesMoved
    for(NSValue *v in dogTouches){
        // stored as NSValues
        DogTouch *dt = (DogTouch *)[v pointerValue];
        // get the touch hash for this stored touch
        NSNumber *hash = [[dt getHash] retain];
        // compare the currently processed UITouch with this DogTouch by hash
        if(hash.intValue == [touch1 hash]){
            [dt moveTouch:[[NSValue valueWithPointer:&locations[0]]retain] topFloor:FLOOR4_HT];
        } else if(count >= 2 && touch2 && hash.intValue == [touch2 hash]){
            [dt moveTouch:[[NSValue valueWithPointer:&locations[1]]retain] topFloor:FLOOR4_HT];
        }
        // have to pass in the height of the top floor here, since moveTouch needs
        // to know about it and it varies across platforms (iPad, iPhone)
    }

dogTouches is an NSArray of NSValues containing pointers to DogTouch objects, which
in turn contain a stored hash for the touch to which they belong, as well as methods
for positioning the hot dogs according to the touch position. ``count`` on that array
easily tells how many hot dogs are grabbed at the moment.

This code deals with a touch event ending (ie a finger being pulled off the screen):

.. code-block:: c

    // the cocoa touch events that just ended
    for(UITouch *touch in touches){
        // our stored touch objects
        for(NSValue *v in dogTouches){
            DogTouch *dt = (DogTouch *)[v pointerValue];
            NSNumber *hash = [[dt getHash] retain];
            // if the touch that just ended has the same hash,
            if([touch hash] == hash.intValue){
                // drop the hot dog associated with that touch
                [dt removeTouch:FLOOR4_HT];
                [dt flagForDeletion];
            }
        }
    }

With this implementation, dog grabbing is faster, more responsive, and less buggy
(and dare I say more fun?) than it ever was during testing. Much better.
