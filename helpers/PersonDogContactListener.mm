//
//  PersonDogContactListener.mm
//  Heads Up Hot Dogs
//
//  Created by Emmett Butler on 12/26/11.
//  Copyright 2011 Sugoi Papa Interactive. All rights reserved.
//

#include "PersonDogContactListener.h"
#include "cocos2d.h"
#include "GameplayLayer.h"

PersonDogContactListener::PersonDogContactListener() : contacts(){
	
}

PersonDogContactListener::~PersonDogContactListener(){
	
}

void PersonDogContactListener::BeginContact(b2Contact* contact){
    fixtureUserData *fAUd = (fixtureUserData *)contact->GetFixtureA()->GetUserData();
    fixtureUserData *fBUd = (fixtureUserData *)contact->GetFixtureB()->GetUserData();
    bool isADog = fAUd->tag == 1;
	bool isBDog = fBUd->tag == 1;
    bool isATarget = fAUd->tag == 2;
	bool isBTarget = fBUd->tag == 2;
	bool isAPerson = fAUd->tag >= 3 && fAUd->tag <= 10;
	bool isBPerson = fBUd->tag >= 3 && fBUd->tag <= 10;
    bool isAGround = fAUd->tag == 100;
	bool isBGround = fBUd->tag == 100;
    bool isAWall = fAUd->tag == 101;
	bool isBWall = fBUd->tag == 101;
    bool isASensor = fAUd->tag >= 103 && fAUd->tag <= 110;
	bool isBSensor = fBUd->tag >= 103 && fBUd->tag <= 110;
    
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
    	personDogContact.fixtureA = contact->GetFixtureA();
        personDogContact.fixtureB = contact->GetFixtureB();
        contacts.push_back(personDogContact);
    }
    else if(isBDog && isAGround){
    	personDogContact.fixtureA = contact->GetFixtureB();
        personDogContact.fixtureB = contact->GetFixtureA();
        contacts.push_back(personDogContact);
    }
    else if(isADog && isBSensor){
    	personDogContact.fixtureA = contact->GetFixtureA();
        personDogContact.fixtureB = contact->GetFixtureB();
        contacts.push_back(personDogContact);
    }
    else if(isBDog && isASensor){
    	personDogContact.fixtureA = contact->GetFixtureB();
        personDogContact.fixtureB = contact->GetFixtureA();
        contacts.push_back(personDogContact);
    }
    else if(isADog && isBWall){
    	personDogContact.fixtureA = contact->GetFixtureA();
        personDogContact.fixtureB = contact->GetFixtureB();
        contacts.push_back(personDogContact);
    }
    else if(isBDog && isAWall){
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