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
	bool isADog = contact->GetFixtureA()->GetUserData() == (void *)1;
	bool isBDog = contact->GetFixtureB()->GetUserData() == (void *)1;
	bool isAPerson = contact->GetFixtureA()->GetUserData() >= (void *)3;
	bool isBPerson = contact->GetFixtureB()->GetUserData() >= (void *)3;

	if((isADog && isBPerson) || (isBDog && isAPerson)){
		contacts.insert(contact->GetFixtureA()->GetBody());
		contacts.insert(contact->GetFixtureB()->GetBody());
	}
}