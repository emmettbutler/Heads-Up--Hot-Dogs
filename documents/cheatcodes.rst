Cheat Codes
===========

Near the end of the Heads Up development cycle, we were looking for some easter eggs
to covertly sprinkle around the app - I guess to put our "signature" on it, in a way.
I like the idea of knowing something about the app that nobody else does, and having
that knowledge be demonstrable in such an obvious way as a secret cheat code, so if
a friend is playing on their phone, I can say "hey check THIS out" and suddenly drop
into Spicy Chorizo Hell Mode*. Yes, this is a self-centered view of my role as the
developer. Sorry. It's fun.

Also, cheat codes are a dying breed, and including some makes Heads Up feel all the
more "retro" (as much as that description stinks)

So the codes are secret, and obviously I'm not revealing them here. But I had fun
implementing the cheat code recognizer.

The codes are entered by performing a specific series of directional swipes at the
level select screen. All of the menu screens in Heads Up actually have their own
main loops in the form of ``tick`` functions, which I sometimes use for running or
switching animations, or in the case of the level screen, moving between the levels
and processing cheats.

The cheat recognizer is pretty simple: every time a directional swipe is performed, it
places a string representing the swipe direction into its buffer, and once the
number of entered swipes is equal to the length of the cheat it's responsible for,
compares the buffer to its "correct" cheat code direction sequence. One of those
might look like

.. code-block:: c

    NSArray *cheatSwipeSequence = @[@"l", @"u", @"r", @"d", @"r", @"u", @"l", @"d"];

After that check, the entered swipes buffer is freed, to allow
the next attempt to be made.

The one other bit is that if a certain amount of time goes by without any input,
the swipes buffer is cleared - that's necessary to allow multiple attempts and
multiple cheat code entries.

Obviously, the strings used to represent the swipe directions could just as easily
be chars or ints, since they really just represent one of four states. I wanted the
sequences to be easy to read, though (so I can remember them!)

I don't know how old-school button sequence cheats are implemented, but I imagine
it's something really similar to this - keeping sequences of entered inputs, validating,
and then releasing for retry.

The one other thing about this implementation is that I was feeling lazy about
learning how Cocoa's built-in gesture recognizer classes work, so I just wrote my own
(certainly an interesting manifestation of laziness). Naively, I first tried simply
comparing the start and end position of the swipe, checking each of the directions
(eg ``last.x > first.x`` means the swipe was to the right) within a four-part ``if...else``.
This didn't work too well, though, since using ``else`` excluded some checks, and
using only ``if`` produced two outputs (eg "u" and "r" for an up-right swipe). That's
fine, but it didn't totally fit what I wanted - I just required the main direction of
the swipe, disregarding the smaller component of its vector.

.. code-block:: c

        if(firstTouch.x < lastTouch.x && swipeLenX > swipeLenY){
            // right swipe
        }
        if(firstTouch.y > lastTouch.y && swipeLenX < swipeLenY){
            // up swipe
        }
        if(firstTouch.y < lastTouch.y && swipeLenX < swipeLenY){
            // down swipe
        }
        if(firstTouch.x > lastTouch.x && swipeLenX > swipeLenY){
            // left swipe
        }

So, in the final version of that bit, I check the larger component of the swipe
vector, which I imagine is very similar to what Cocoa's recognizers do for directional
swipes.

*\*Spicy Chorizo Hell Mode may or may not actually exist*
