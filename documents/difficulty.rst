This was originally going to be one huge post including both difficulty tuning and
usability, but I've written enough about both to warrant two separate posts.

Difficulty Tuning
-----------------

We knew from early in the Heads Up project that the flow of gameplay would center on
hot dogs falling more and more frequently. We were looking for ways to gradually
ramp up the difficulty per game in a semitransparent way.
We wanted players to not really notice the difficulty ramp, so that without realizing
it they'd end up in some arcade zen. Originally, we had the idea that
having more people on screen would make the game harder, so we also slowly ramped up
the number of people on screen as well as the speed of falling hot dogs. Pretty
quickly, though, we realized that having more people on screen actually made things
way easier, so we allowed the people spawn speed to remain constant.

We also tried shortening the amount of time a hot dog could live on the ground before
decaying as a method of increasing difficulty, but our attempts at this made the
game way too hard - after a short time, hot dogs wouldn't sit on the ground at all,
making things very difficult. That idea was eventually scrapped in favor of simplicity.

At first, the gradual decrement of the hot dog spawn rate was based on time: at
certain time intervals, the rate would be decremented by some discrete value (eg
at 30s, delay -= .5). The main problem with this method was that a player who was
slower at mastering the mechanic would be faced with a huge challenge before they
were ready for it and the game would feel way too hard.

Instead of time benchmarks, spawn-time decrementing in the production version is
based on point benchmarks, so the
effective difficulty of the game is dependent on how well the player has done so far.
For example: delay -= .5 at 10000 points, 20000 points, etc.
This way, slower players still feel appropriately challenged. This strategy alone
doesn't stop players from feeling that the game gets too hard too fast, but it does
put players on the same footing, so at least most players should feel that the
difficulty increases at the same rate.

Interesting note: when the timing of these difficulty increases is literally identical
across player skill levels (ie increase at 30s, 1m, 90s, etc....), some players
complain that the game gets difficult too fast. However, when the timing is adjusted
based on player skill (ie different for everyone), players feel like it's consistent.
Interesting how that works.

For a while, the delay between hot dog spawns was the only parameter being adjusted
to increase difficulty. Somewhere along the way, we decided that having 18 hot dogs
on the screen at once might be unmanageable. We introduced a maximum number of
dogs onscreen, in an attempt to mitigate that issue. This ended up becoming another
parameter used to affect the difficulty - increasing at certain point
benchmarks. For example: at 50,000 points, increase the maximum from 7 to 8. This,
combined with the spawn delay decrements, proved to be enough to create a frantic
feeling in the players.

This also leads to an emergent wave pattern in the hot dog spawns. Enforcing a maximum
means that even if the spawn delay time is past, a new dog won't spawn unless there
are less than the max onscreen. If not, it will wait to spawn until some dogs
are removed. This means that if the max is hit and all of the onscreen dogs leave
on a single head, more will come down all at once. This creates the feeling that
things are frantic but still manageable.

I'm reminded of a funny story from testing: I noticed one day that one of the testers
had posted a Game Center high score higher than I'd ever gotten - somewhere in the
150k area. Thinking I was the best Heads Up! Hot Dogs player in the world, I
immediately started a game trying to beat his score. After passing about 50000
points I noticed that I had neglected to account for someone being this good at the
game. The dog spawn rate didn't increase past that point, and gameplay quickly became
boring for a player who was practiced enough to manage the five hot dogs.

Side note: I missed the guy's high score by about 100 points. T__T

This was a great catch, though, since it led me to ensure that skilled players
wouldn't ever reach a plateau of difficulty. I made sure that after a certain point,
the game would increase in difficulty much faster than it had before, almost guaranteeing
that high-level players would still have something to do up there at the top.

What does all of this mean? I think we did a good job of creating a curve that feels
fairly transparent to the player. Maybe that's a goal for arcade games with
mechanics as simple as ours.
