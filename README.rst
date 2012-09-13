Heads Up! Hot Dogs - technical postmortem
=========================================

Heads Up! Hot Dogs is written in Objective-C++ and relies heavily on two
primary open-source libraries:

-Cocos2D, a 2D game engine
-box2d, a 2D physics world

Cocos2D is used to handle screen transistions, sprite drawing/animation, touch
location detection, particle effects, and more.

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
the z-indexing and collision filtering problem by dividing it into only four
components.

Game Objects
------------

Most actors are paired with physics bodies, and the actors' (sprites)
positions are updated each iteration with the position of their corresponding
body.

Hot Dogs
--------

Each hot dog in Heads Up! is represented by a single physics body. Each one
has two fixtures, which serve different purposes:

-One fixture (the "collision" fixture) is the same size as the hot dog sprite,
and is set to collide with people and walls. This is also the fixture at which
the cop aims.
-The other fixture (the "grab" fixture) does not collide with anything, and is
used to detect touches on the hot dog. This fixture was added since grabbing
dogs by their relatively small collide filter proved to be annoyingly
difficult.

When a hot dog is spawned, it may only collide with the walls,
the ceiling, and one of the four levels of floor. Once it hits the ground or
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

-The "hitbox" fixture is a nearly two-dimensional fixture that only collides
with hot dogs. It is positioned individually for each person sprite so that it
is approximately at their forehead level. This fixture is essentially a flat
shelf on the head of each person - flat to avoid the situation in which a dog
is pushed forward by someone's face.
-The "walking" fixture is a square fixture (the size of the person's sprite
minus the head) that collides with one of the four floor surfaces. The people
in Heads Up! can be thought of as "sliding" across the frictionless flat
ground surfaces.

The collision filtering for "people" actors posed a bit of a challenge. In
essence, the requirements were as follows:

-Don't allow one person to knock a dog off of another's head
-Allow hot dogs full range of motion while they're on a head
-Don't allow a person to knock a dog away while it's above another person's
head, having already bounced off of it

I my first attempt at this was the creation of prismatic joints between the
person's head fixture and the dog's collision fixture. This caused a host of
issues: it both caused and was adversely affected by major slowdown, it did
not allow vertical motion of the hot dogs on heads, and people could still
knock each other's dogs off if they got close enough.

After a few iterations, I realized that collision filtering was the only right
way to go, since any other solution to the issue would probably restrict the
dogs' motion - an impossibility in an action game about bouncing franks.
However, box2d uses a single 32-bit integer for its collision filtering,
meaning in practice that there can only exist 32 collision
filtering categories. A few of these were taken up by the walls, floors, hot
dogs, person "walking" fixture A few of these were taken up by the walls,
floors, hot dogs, and person "walking" fixtures.

Each new person who walks onscreen is given a different collision filter than
all of the others on screen. This is controlled by a counter which loops to
the lowest free collision filter when it reaches the maximum of a 32-bit
value. In this way, collisions between dogs riding heads are avoided.
