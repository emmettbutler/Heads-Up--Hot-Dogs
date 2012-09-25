//
//  PersonDogContactListener.h
//  Heads Up Hot Dogs
//
//  Created by Emmett Butler on 12/26/11.
//  Copyright 2011 Sugoi Papa Interactive. All rights reserved.
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct PersonDogContact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const PersonDogContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class PersonDogContactListener : public b2ContactListener {
	public:
			std::vector<PersonDogContact>contacts;

			PersonDogContactListener();
			~PersonDogContactListener();

			virtual void BeginContact(b2Contact* contact);
			virtual void EndContact(b2Contact* contact);
			virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
			virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
};