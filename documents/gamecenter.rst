This is part of a series of stories about implementation details in Heads Up, since
I think it's important to reflect on and record lessons learned after a project of
this size. Workiing on the same project for 11 months yielded a lot of new knowledge
for me, and I want to make sure I capture as much of it as possible in writing.

It would have been really awesome to be writing these as I was first coming up with
the ideas, but unfortunately I didn't have the foresight or motivation to keep a dev
log as I was working, so this retrospective will have to do. I think it still has
the potential to provide interesting perspective.

Game Center Integration
=======================

There were a few different actions and use cases that we wanted to support with
the iOS Game Center:

- Players should be able to see their high scores for each level over time
- Provide a bunch of achievements that are reported during the round, for quick
  feedback
- Show an achievement unlock banner during gameplay for each achievement
- Don't report the same achievement twice in a round

The first one is really simple: I just unconditionally send the player's score to
game center as soon as the round ends. At first I thought it made sense to check
if a new high score was set and only report if so - it
might reduce the number of reports that had to be made to game center. The problem
was the case where a player has a very high score set yesterday (or last week) and
fails to beat their score today. If only a new high score was reported to GC, they
wouldn't see their daily and weekly highs. So, instead of trying to keep track of
these myself, I chose to let game center take care of it and report unconditionally.

Achievement reporting also isn't so bad, but there's one clever bit that I'm sort of
happy with. My intuitive thought process about the way I'd prefer to write achievement
reporting code involves a simple conditional that can be called each update cycle, which
might look like this

.. code-block:: c

    // reports an achievement when the player survives for two minutes without losing a hotdog
    if(!_hasDroppedDog){
        if(time/60 > 240){
            [reporter reportAchievementIdentifier:@"nodrops_240" percentComplete:100];
        }
    }

The obvious problem with putting this conditional report in the main loop is that
for conditions that can be satisfied for more than one frame (ie all of them), this
function will be called multiple times when it only really needs to be called once.
Naively, I would set a separate lock variable for each of the achievements to ensure
that they only get reported once, but that's a big waste of space. Simpler (and I
think more elegant) is the solution I ended up using: maintain a dictionary of the
achievements and check this dictionary before reporting.

The dictionary is loaded with game center's stored achievements when the app loads,
so we know which the player has done already. The reporter class then contains a
test for completion in the dictionary, and only if the achievement has not been
completed is the score reported. This check happens within the ``reporter`` object's
``reportAchievementIdentifier`` method, so I don't have to worry about locking it
externally. Obvioously, the dictionary gets updated each time
an achievement is reported to game center.

.. code-block:: c

    -(void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent{
        GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
        if(achievement && achievement.percentComplete < 100){
            achievement.percentComplete = percent;
            if([[HotDogManager sharedManager] isInGame]){
                achievement.showsCompletionBanner = YES;
            } else {
                achievement.showsCompletionBanner = NO;
            }
            [achievement reportAchievementWithCompletionHandler:^(NSError *error){
                if(error != nil){
                    DLog(@"Error reporting achievement to game center: %@", identifier);
                } else {
                    DLog(@"Reported achievement to game center: %@", identifier);
                }
            }];
        }
    }

That pretty well alleviates the problem of reporting the same achievement multiple
times, and it allows me to write simple, friendly code to define achievement conditions
instead of defining a tangle of lock variables.


*~emmett*
