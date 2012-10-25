Touch Tracking
==============

Game involves lots of grabbing physics objecs and throwing them around
Problem: keep each touch responsible for the same hot dog throughout its lifetime
also allow multitouch

was easy when multitouch wasn't a requirement
multitouch made it important to separate dogs based on which touch was holding them

mouse joints, border detection, grab state

naive approach: assume that touches will not move more than a certain distance per
frame
calculate the distance between the touch's current position and its last position
to see if it's the "same" touch or not.
Actually worked ok, in that it did well at separating touches from each other
it imposed a max speed on dragging
if drag was faster than that, the dog would freeze and still look grabbed
wierd bugs like dogs jumping into the corners, getting sucked offscreen by the edges
jumping between touches
generally bad and slow

find out about touch hashes
each touch has a single unique ID that it retains throughout its lifespan
suddenly this problem is much easier
just compare IDs, if the same, touch is the same touch
keep hot dog positioned under only one touch at a time

.. code-block:: c

    // in CCTouchesMoved
    for(NSValue *v in dogTouches){
        // stored as NSValues
        DogTouch *dt = (DogTouch *)[v pointerValue];
        // get the touch hsah for this stored touch
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

touches are represented s DogTouch objects
kept in a global array of these objects
counting these objecs tells how many touches are currently grabbing dogs (0-2)
