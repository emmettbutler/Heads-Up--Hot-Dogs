Heads Up! Hot Dogs - technical postmortem
=========================================

Heads Up! Hot Dogs is written in Objective-C++ and relies heavily on two
primary open-source libraries:

- Cocos2D, a 2D game engine
- box2d, a 2D physics world

Cocos2D is used to handle screen transistions, sprite drawing/animation, touch
location detection, particle effects, and some action timing.

Box2d provides a physics world simulation and certain entry points to that
simulation. This phsyical simulation is used in the main game loop to handle
the creation, destruction, and movement of game objects, as well as their
collision detection.

Basics
------

Since box2d and cocos2d are strictly two-dimensional, the illusion of depth is
created with careful z-indexing of sprites and collision filtering on physics
bodies. The ground on which the people walk and hot dogs land is actually four
discrete "floors" stacked on each other. This number was kept low to simplify
the z-indexing and collision filtering problem.

Game Objects
------------

Most actors are paired with physics bodies, each of which has one or more
associated fixtures, used either as a collision detector, a hitbox for
cocos2d, or both. In a fairly common box/cocos idiom, the actors' (sprites)
positions are updated each iteration with the position of their corresponding
body.

Hot Dogs
--------

Each hot dog in Heads Up! is represented by a single physics body. Each one
has two attached fixtures:

- One fixture (the "collision" fixture) is the same size as the hot dog sprite,
and is set to collide with people and walls. This is also the fixture at which
the cop character aims his gun.
- The other fixture (the "grab" fixture) does not collide with anything, and is
about five times taller and wider than the dog's sprite.
It's used to detect touches on the hot dog. This fixture was added since grabbing
dogs by their relatively small collide filter proved to be annoyingly
difficult.

When a hot dog is spawned, it may only collide with the walls,
the ceiling, and one of the four levels of floor (chosen randomly). Once it hits
the ground or
is touched, it gains the ability to collide with any person onscreen. Once
it collides with a person, its collision filtering is restricted to *only* the
head of the person it is on. As a result, hot dogs physically behave as if
they are "behind" or "in front" of certain actors, since their collision
filter is defined by the head they're currently riding (usually - more on this
later). Once a hot dog is deemed to be no longer on a head, its collision filters
are restored to allow collisions with any person.

People
------

People (with the exception of the cop) also consist of a single physics body
with two fixtures:

- The "hitbox" fixture is a nearly two-dimensional (very thin) fixture that only collides
with hot dogs. It is positioned individually for each person sprite so that it
is approximately at their forehead level. This fixture is essentially a flat
shelf on the head of each person - flat to avoid the situation in which a dog
is pushed forward by someone's face.
- The "walking" fixture is a square fixture (the size of the person's sprite
minus the head) that collides with one of the four floor surfaces. The people
in Heads Up! are literally "sliding" across the frictionless flat
ground surfaces. Truthfully, these fixtures probably don't need to be any bigger
than thin horizontal slivers.

Special Characters
------------------

Level Effects
-------------

Collision Filtering
-------------------

The collision filtering for "people" actors posed a bit of a challenge. In
essence, the requirements were as follows:

- Don't allow one person to knock a dog off of another's head
- Allow hot dogs full range of motion while they're on a head
- Don't allow a person to knock a dog away while it's above another person's
head after it's bounced.

Each new person who walks onscreen is given a different collision filter than
all of the others on screen. This is controlled by a counter which loops to
the lowest free collision filter when it reaches the maximum of a 32-bit
value. In this way, collisions between dogs riding heads are avoided, modulo the
occasional case in which two people with the same collision filter occupy the screen
at once. These cases are rare enough to not constitute a high priority bug.

Touch Sensing
-------------

Early implementations
---------------------

My first attempt at managing the dog-on-head interaction was the creation of prismatic joints between the
person's head fixture and the dog's collision fixture. This caused a host of
issues: it did
not allow vertical motion of the hot dogs on heads, and people could still
knock each other's dogs off if they got close enough. Additionally, the frequent and
simultaneous creation and destruction of physics joints caused an unnaceptable drop in
framerate, which in turn caused the joints themselves to behave erratically - a
vicious circle of slowdown.

After a few iterations, I realized that collision filtering was the only right
way to go, since any other solution to the issue would probably restrict the
dogs' motion - an impossibility in an action game about bouncing franks.
However, box2d uses a single 32-bit integer for its collision filtering,
meaning in practice that there can only exist 32 collision
filtering categories. A few of these were taken up by the walls, floors, hot
dogs, person "walking" fixtures.

Another challenge that eventually led to major slowdown in early versions was the
logic for moving characters across the screen. My decreasingly naive understanding
of common box2d practices led me to a number of simplistic and inefficient solutions
to problems, which were later improved iteratively.

My first stab at moving characters across the play area involved a convoluted series
of cocos2d actions and sequences, each of which called a function that either
applied some physical force or ran an animation. The characters would move across
a frictionless floor surface after being pushed by an ApplyForce(), not changing
speed due to lack of friction. Stopping the character was a matter of applying a
force of equal magnitude in the opposite direction. Predictably, this caused problems.
There was no logic enforcing the stillness of a "stopped" character, so characters
frequently glided slowly backward upon stopping to play their idle animation. This
method also opened my eyes to the relative expense of frequent calls to ApplyForce()
as it caused a marked drop in framerate.

Another notable stop in the iterations of this challenge was creating all character
bodies as static and manually moving them with my own code. This worked nicely
and saved a lot of framerate, but with the unacceptable caveat that box2d does not
apply frictional forces to manually positioned static bodies - resulting in
hot dogs sliding freely off of people's heads.

The current (final?) incarnation of this code does not use cocos2d actions for timing
or movement, only for character animation. Timing is controlled by the global
clock, and each character has a defined number of units to move per tick. Instead
of applying forces to the bodies, a single call to SetVelocity() (or three for
idling characters) is used to control the specific movement patterns. This still saves
a significant amount of processing time over the forces method.


Technical / Development Lessons
-------------------------------

The project as a whole has taught me:

- the value of beginning with a simple, naive implementation and then quickly iterating and optimizing.
- it's better to show nothing at all than to show a buggy feature
- seomthing about bloat/feature creep that I'm not sure of, should reflect on how to balance feature requests with simplicity

- Touch hashes
