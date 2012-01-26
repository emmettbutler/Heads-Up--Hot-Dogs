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
    bool isADog = contact->GetFixtureA()->GetUserData() == (void *)1;
	bool isBDog = contact->GetFixtureB()->GetUserData() == (void *)1;
	bool isAPerson = contact->GetFixtureA()->GetUserData() >= (void *)3;
	bool isBPerson = contact->GetFixtureB()->GetUserData() >= (void *)3;
    
    MyContact myContact;
    
    //Coming out of this collision, dogs will always be first in myContact
	if(isADog && isBPerson){
        myContact.fixtureA = contact->GetFixtureA();
        myContact.fixtureB = contact->GetFixtureB();
    } 
    else if(isBDog && isAPerson){
    	myContact.fixtureA = contact->GetFixtureB();
        myContact.fixtureB = contact->GetFixtureA();
    }
    contacts.push_back(myContact);
}

void MyContactListener::EndContact(b2Contact* contact){
	MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(contacts.begin(), contacts.end(), myContact);
    if(pos != contacts.end()){
        contacts.erase(pos);
    }
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold){
	
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse){

}