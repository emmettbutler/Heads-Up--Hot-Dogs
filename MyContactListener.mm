//
//  MyContactListener.cpp
//  Angry Squirrels
//
//  Created by Emmett Butler on 12/26/11.
//  Copyright 2011 NYU. All rights reserved.
//

#include "MyContactListener.h"
#include "cocos2d.h"

MyContactListener::MyContactListener() : contacts(){
	
}

MyContactListener::~MyContactListener(){
	
}

void MyContactListener::BeginContact(b2Contact* contact){
	
}

void MyContactListener::EndContact(b2Contact* contact){
	
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold){
	
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse){
	bool isABall = contact->GetFixtureA()->GetUserData() == (void *)1;
	bool isBBall = contact->GetFixtureB()->GetUserData() == (void *)1;
	bool isABox = contact->GetFixtureA()->GetUserData() == (void *)2;
	bool isBBox = contact->GetFixtureB()->GetUserData() == (void *)2;

	if((isABall && isBBox) || (isBBall && isABox)){
		contacts.insert(contact->GetFixtureA()->GetBody());
		contacts.insert(contact->GetFixtureB()->GetBody());
	}
}