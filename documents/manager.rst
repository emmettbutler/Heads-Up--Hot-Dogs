HotDogManager
=============

There was a point in Heads Up development when I started realizing that I had to
account for the iOS actions surrounding its execution - home button taps, double
taps, sleep button presses, music and sfx changes, and things like that. Yes, this
moment only came after months of never thinking about these things (it's my first
app, ok?) Before then I'd been mostly avoiding the questions that couldn't be solved
by not allowing the app to run in the background, until I noticed the double-tap
home button question.

Some of the boilerplate that Cocos had put into the project paused and restarted the
gameplay automatically on ``applicationWillResignActive`` and ``applicationDidBecomeActive``,
the functions that the app delegate calls when the home button is double-tapped to
bring up the little list of apps on the bottom of the screen. This was great for me,
since I didn't need to worry about how to do that pausing myself...

until I implemented an in-game pause screen. Immediately I ran into the issue where
every time the user dismissed the app list, the action on screen would restart,
including when the pause screen was up. This meant that the pause menu would stay
there with action running behind it - obviously not a good situation.

My immediate reaction to this is to tell the app delegate about when the pause screen
is up, so it knows when to start the action and when not to - but the app delegate
and the gameplay screen are in different and apparently unrelated files. I don't
really remember what I tried, but I quickly realized that this was a pretty good use
case for a singleton (a class that is guaranteed to only be instantiated a maximum
of one time).

So now there's a ``HotDogManager`` singleton that maintains a state flag called
``isPaused`` that indicates whether or not the gameplay pause screen is displayed.
Since there's only one instance of the manager, the app delegate can just check it
and see whether it should restart action.

.. code-block:: c

    // in applicationDidBecomeActive
    if(![[HotDogManager sharedManager] isPaused]){
        [[CCDirector sharedDirector] resume];
    }

It works quite nicely. That was the original use case, and since then I added a few
more flags to the singleton to help keep track of more global state - things like
sfx on/off, app running time, functions for reporting analytics events, and some more.

Another awesome side effect of this is that now that the app always knows if it's
paused or not, I can let it run in the background and display the pause screen
if the user leaves and comes back in the middle of a round. This actually works by
always resuming the game loop upon the app entering the foreground, and then checking
within the game loop whether to display a pause screen. Something like

.. code-block:: c

    // in the game loop...
    if([[HotDogManager sharedManager] isPaused] && !pauseLock){
        // display the ingame pause screen and freeze the action
        [self pauseButton:[NSNumber numberWithBool:true]];
        // make sure we only send the pause command once
        pauseLock = true;
    }

When the app enters the background, ``isPaused`` gets set true.
Then as soon as the app comes back up, one cycle of the main loop runs and then this
code gets hit, freezing the action before the second loop.

Beyond being pretty cool, I feel like this  functionality might improve engagement
or retention or some other marketing word since the user isn't always forced to
restart their games when they get phone calls or whatever.

This was my first time using a singleton, and if the idea had occurred to me sooner,
I probably could have done an even better job of storing all of the global state in
this manager, similar to how cocos does it with the CCDirector. But I suppose that's
the next project.

I've thought of so, so many ways I could refactor this code and make it way nicer.
Effort probably better spent on making the next project awesome, though.

*~emmett*
