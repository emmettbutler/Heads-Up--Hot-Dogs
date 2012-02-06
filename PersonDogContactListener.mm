//
//  PersonDogContactListener.mm
//  Heads Up Hot Dogs
//
//  Created by Emmett Butler on 12/26/11.
//  Copyright 2011 NYU. All rights reserved.
//

#include "PersonDogContactListener.h"
#include "cocos2d.h"

PersonDogContactListener::PersonDogContactListener() : contacts(){
	
}

PersonDogContactListener::~PersonDogContactListener(){
	
}

void PersonDogContactListener::BeginContact(b2Contact* contact){
    bool isADog = contact->GetFixtureA()->GetUserData() == (void *)1;
	bool isBDog = contact->GetFixtureB()->GetUserData() == (void *)1;
    bool isATarget = contact->GetFixtureA()->GetUserData() == (void *)2;
	bool isBTarget = contact->GetFixtureB()->GetUserData() == (void *)2;
	bool isAPerson = contact->GetFixtureA()->GetUserData() >= (void *)3;
	bool isBPerson = contact->GetFixtureB()->GetUserData() >= (void *)3;
    bool isAGround = contact->GetFixtureA()->GetUserData() >= (void *)100;
	bool isBGround = contact->GetFixtureB()->GetUserData() >= (void *)100;
    
    PersonDogContact personDogContact;
    
    //Coming out of this collision, dogs will always be first in myContact
	if(isADog && isBPerson){
        personDogContact.fixtureA = contact->GetFixtureA();
        personDogContact.fixtureB = contact->GetFixtureB();
        contacts.push_back(personDogContact);
    } 
    else if(isBDog && isAPerson){
    	personDogContact.fixtureA = contact->GetFixtureB();
        personDogContact.fixtureB = contact->GetFixtureA();
        contacts.push_back(personDogContact);
    }
    else if(isADog && isBTarget){
    	personDogContact.fixtureA = contact->GetFixtureA();
        personDogContact.fixtureB = contact->GetFixtureB();
        contacts.push_back(personDogContact);
    }
    else if(isBDog && isATarget){
    	personDogContact.fixtureA = contact->GetFixtureB();
        personDogContact.fixtureB = contact->GetFixtureA();
        contacts.push_back(personDogContact);
    }
    else if(isADog && isBGround){
    	personDogContact.fixtureA = contact->GetFixtureB();
        personDogContact.fixtureB = contact->GetFixtureA();
        contacts.push_back(personDogContact);
    }
    else if(isBDog && isAGround){
    	personDogContact.fixtureA = contact->GetFixtureB();
        personDogContact.fixtureB = contact->GetFixtureA();
        contacts.push_back(personDogContact);
    }
}

void PersonDogContactListener::EndContact(b2Contact* contact){
	PersonDogContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<PersonDogContact>::iterator pos;
    pos = std::find(contacts.begin(), contacts.end(), myContact);
    if(pos != contacts.end()){
        contacts.erase(pos);
    }
}

void PersonDogContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold){
	
}

void PersonDogContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse){

}