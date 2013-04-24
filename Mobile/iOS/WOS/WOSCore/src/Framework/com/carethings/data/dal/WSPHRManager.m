/*!
 *  @file Interaction.h
 *
 *  @details	Represents an interaction (utterance) within the wStack framework.
 *              When used in an agent-based environment, represents an utterance between agents. Multiple utterances are required to represent a conversation.
 *
 *  @Author     Larry Suarez
 *  @package    com.carethings.domain
 *
 *  Copyright (c) 2011, CareThings, Inc.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 *	1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation
 *         and/or other materials provided with the distribution.
 *	3. Neither the name of CareThings nor the names of its contributors may be used to endorse or promote products derived from this software without specific
 *         prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 *  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <AVFoundation/AVFoundation.h>
#import "WSPHRManager.h"
#import "WSResourceManager.h"
#import "ActivityDAO.h"
#import "AssetDAO.h"

NSString* const SQLCipherManagerErrorDomain = @"SQLCipherManagerErrorDomain";


@implementation WSPHRManager

- (BOOL)execute:(NSString *)sqlCommand error:(NSError **)error {
	const char*	sql = [sqlCommand UTF8String];
	char*		errorPointer;
	
	if (sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], sql, NULL, NULL, &errorPointer) != SQLITE_OK) {
		if (error) {
			NSString*		errMsg		= [NSString stringWithCString:errorPointer encoding:NSUTF8StringEncoding];
			NSString*		description	= @"An error occurred executing the SQL statement";
			NSDictionary*	userInfo		= [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, errMsg, NSLocalizedFailureReasonErrorKey, nil];
			
			*error = [[NSError alloc] initWithDomain:SQLCipherManagerErrorDomain code:ERR_SQLCIPHER_COMMAND_FAILED userInfo:userInfo];
			sqlite3_free(error);
		}
		return NO;
	}
	return YES;
}


- (void) initializePHR {
	NSError*	err = nil;
	NSArray*	schemaCommands = [[NSArray alloc] initWithObjects:
                              @"CREATE TABLE Activity (objectID CHAR(40) NOT NULL, creationTime DATETIME default CURRENT_TIMESTAMP NOT NULL , reason VARCHAR(25), description VARCHAR(150), worldModel VARCHAR(255), type VARCHAR(25), code VARCHAR(150), userCode VARCHAR(150), vendorType VARCHAR(25), value VARCHAR(50), startTime DATETIME, endTime DATETIME, relatedID CHAR(40), goalID CHAR(40), taskID CHAR(40), rewardID CHAR(40), data blob,  archived smallint DEFAULT 0,  sysID varchar(150),  userID varchar(150), originator varchar(50), location varchar(50), locationCode varchar(50), dayOfWeekOfStudy INTEGER, hourOfDayOfStudy INTEGER, numberOfSteps INTEGER, weekOfStudy INTEGER, weeklyGoal INTEGER, instanceID varchar(150), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Alert (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), message VARCHAR(25), detailMessage VARCHAR(200), priority CHAR(10), relatedID VARCHAR(40), PRIMARY KEY (objectID))",
                              @"CREATE TABLE AppState (objectID CHAR(40) NOT NULL, creationTime DATETIME default CURRENT_TIMESTAMP NOT NULL, active smallint, description VARCHAR(150), worldModel VARCHAR(255), simIndex INTEGER, PRIMARY KEY (objectID))",
                              @"CREATE TABLE Application (objectID char(40) NOT NULL PRIMARY KEY,creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,description VARCHAR(150), worldModel VARCHAR(255),name varchar(150),ontology varchar(150),url varchar(150),version varchar(50),image blob, publisher varchar(100), numAnalytic varchar(30), analytic varchar(100), price varchar(20))",
						      @"CREATE TABLE Asset (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), assetID VARCHAR(40), fileURL VARCHAR(125), timeLength CHAR(10), fileSize CHAR(10), relatedID VARCHAR(40), data blob, originator varchar(50), location varchar(50), locationCode varchar(50), patientID varchar(40), assetType int, archived smallint DEFAULT 0, assetArchived smallint DEFAULT 0, container varchar(255), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Behavior (objectID char(40) NOT NULL PRIMARY KEY, creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, description VARCHAR(150), behaviorType INTEGER, decoratedName VARCHAR(255), behaviorState INTEGER, concept VARCHAR(255), monitorWatcher double, reactorActivation VARCHAR(255), monitorEnd VARCHAR(255), monitorEndCode blob, monitorEndLanguage int, monitorEndCodeLen INTEGER, monitorEndCodeValid INTEGER, monitorException VARCHAR(255), monitorExceptionCode blob, monitorExceptionLanguage int, monitorExceptionCodeLen INTEGER, monitorExceptionCodeValid INTEGER, startActions VARCHAR(255), startActionsCode blob, startActionsLanguage int, startActionsCodeLen INTEGER, startActionsCodeValid INTEGER, stopActions VARCHAR(255), stopActionsCode blob, stopActionsLanguage int, stopActionsCodeLen INTEGER, stopActionsCodeValid INTEGER, protocol blob, protocolCode blob, protocolLanguage int, protocolCodeLen INTEGER, protocolCodeValid INTEGER, knowledge VARCHAR(255),relatedID VARCHAR(40))",
                              @"CREATE TABLE CDPHProtocolHistory (objectID CHAR(40) NOT NULL, creationTime DATETIME default CURRENT_TIMESTAMP NOT NULL , visit VARCHAR(25), interventionSysID varchar(150), description VARCHAR(150), worldModel VARCHAR(255), abstractionDate DATETIME, clientID CHAR(40),   abstractorID varchar(50),  siteID varchar(50), history text, PRIMARY KEY (objectID))",
                              @"CREATE TABLE CarePlan (xml VARCHAR(1000),objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)",
                              @"CREATE TABLE CarePlanCase (lastInteractionSysID VARCHAR(50),carePlanID VARCHAR(50),objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)",
                              @"CREATE TABLE CasePatient (caseID char(40) NOT NULL, patientID CHAR(40) NOT NULL, objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
                              @"CREATE TABLE Category (objectID CHAR(40) NOT NULL PRIMARY KEY,creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,description VARCHAR(150), worldModel VARCHAR(255),name varchar(100), ontology varchar(150))",
                              @"CREATE TABLE CategoryApplication (categoryID char(40) NOT NULL, applicationID CHAR(40) NOT NULL, objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
                              @"CREATE TABLE EventType (objectID CHAR(40) NOT NULL PRIMARY KEY,creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,description VARCHAR(150), worldModel VARCHAR(255),lookup VARCHAR(25),title VARCHAR(25),category CHAR(40))",
                              @"CREATE TABLE Features (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), eula VARCHAR(255), hasEula smallint DEFAULT 0, splashScreen blob, hasAuthentication smallint DEFAULT 1, hasReminders smallint DEFAULT 0, version CHAR(40), hasSocial smallint DEFAULT 0, socialParticipantToProvider smallint DEFAULT 0, socialProviderToParticipant smallint DEFAULT 0, socialParticipantToParticipant smallint DEFAULT 0, hasSplashScreen smallint DEFAULT 0, serviceSOPDrugInformation smallint DEFAULT 0, hasProgress smallint DEFAULT 0, hasInformation smallint DEFAULT 0, informationXMLProtocol blob, hasSensors smallint DEFAULT 0, hasAlerts smallint DEFAULT 0, hasGoals smallint DEFAULT 0, hasActivities smallint DEFAULT 0, hasRewards smallint DEFAULT 0, hasBehaviorPatterns smallint DEFAULT 0, hasGeozones smallint DEFAULT 0, hasBehaviors smallint DEFAULT 0, hasTheme smallint DEFAULT 0, hasGaming smallint DEFAULT 0, requireSettings smallint DEFAULT 0, requireSettingAlarm smallint DEFAULT 0, requireSettingAuthentication smallint DEFAULT 0, requireSettingResearcher smallint DEFAULT 0, requireSettingSite smallint DEFAULT 0, requireSettingGeozone smallint DEFAULT 0, requireSettingParticipantId smallint DEFAULT 0, requireSettingUserName smallint DEFAULT 0, hasVisitedSettings smallint DEFAULT 0, hasPhases smallint DEFAULT 0, hasVirtualCoach smallint DEFAULT 0, hasLanguages smallint DEFAULT 0, hasDesktopPhoto smallint DEFAULT 0, hasResearcherLanguage smallint DEFAULT 0, hasParticipantIDSettings smallint DEFAULT 0, hasUserNameSettings smallint DEFAULT 0, hasResearcherSettings smallint DEFAULT 0, hasSiteSettings smallint DEFAULT 0, PRIMARY KEY (objectID))",
                              @"CREATE TABLE GeoPoint (objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,latitude double, longitude double, relatedID char(40), accuracy double)",
                              @"CREATE TABLE Geozone (name varchar(50),objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,relatedID char(40),alertDistance varchar(30) NOT NULL DEFAULT \"1 kilometer\", active integer NOT NULL DEFAULT 0)",
                              @"CREATE TABLE Goal (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), name VARCHAR(255), shortDescription VARCHAR(255), instructions VARCHAR(255), activation VARCHAR(255), personalValue VARCHAR(255), expectationOfSuccess VARCHAR(255), reward varchar(255), actionPlan VARCHAR(255), ontology varchar(150), completionTime varchar(40), code varchar(150), startTime varchar(40), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Log (objectID CHAR(40) NOT NULL, creationTime DATETIME default CURRENT_TIMESTAMP NOT NULL , description VARCHAR(150), worldModel VARCHAR(255), logRecord VARCHAR(150), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Memo (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), memoID VARCHAR(40), fileURL VARCHAR(125), timeLength CHAR(10), fileSize CHAR(10), relatedID VARCHAR(40), soundData blob, PRIMARY KEY (objectID))",
                              @"CREATE TABLE Patient (lastName VARCHAR(50),firstName VARCHAR(50),dateOfBirth DATETIME,patientNum CHAR(40),gender CHAR(1),weight CHAR(4),height CHAR(4),objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,deviceToken VARCHAR(70),sample varchar(20),visit1 varchar(20),visit2 varchar(20),visit3 varchar(20),visit4 varchar(20),visit5 varchar(20),lastVisit1Interaction varchar(40),lastVisit2Interaction varchar(40),lastVisit3Interaction varchar(40),lastVisit4Interaction varchar(40),lastVisit5Interaction varchar(40),finalReview varchar(20),lastFinalReviewInteraction varchar(20),visit1Status integer,visit2Status integer,visit3Status integer,visit4Status integer,visit5Status integer, primaryClinic varchar(70), primaryClinicCode varchar(70), rewardPoints varchar(20), points varchar(20), photo blob, photo2 blob, photo3 blob, coachFilePath varchar(120), welcomeCoach smallint, coachPhoto1 blob, coachPhoto2 blob)",
                              @"CREATE TABLE PatientEducation ( objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, eduType varchar(100), eduSource varchar(100), eduData blob, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
                              @"CREATE TABLE PhysicianNote (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), physician VARCHAR(100), note VARCHAR(1000), relatedID VARCHAR(40), priority VARCHAR(100), status VARCHAR(100), toParticipant VARCHAR(100), urlOfNote VARCHAR(100), PRIMARY KEY (objectID))",
                              @"CREATE TABLE ProtocolHistory (objectID CHAR(40) NOT NULL, creationTime DATETIME default CURRENT_TIMESTAMP NOT NULL , interventionSysID varchar(150), description VARCHAR(150), worldModel VARCHAR(255), history text, relatedID CHAR(40), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Provider ( clinicName VARCHAR(150), address VARCHAR(150), city CHAR(40), state CHAR(40), objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
                              @"CREATE TABLE ProviderPatient (providerID char(40) NOT NULL, patientID CHAR(40) NOT NULL, objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
                              @"CREATE TABLE RenderStyle (objectID CHAR(40) NOT NULL, description VARCHAR(150), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, textColor VARCHAR(50), textFontSize VARCHAR(50), textFontFamily VARCHAR(50), questionColor VARCHAR(50), questionFontSize VARCHAR(50), questionFontFamily VARCHAR(50), headerColor VARCHAR(50), headerFontSize VARCHAR(50), headerFontFamily VARCHAR(50), choiceTextColor VARCHAR(50), choiceFontSize VARCHAR(50), choiceFontFamily VARCHAR(50), responseBorderColor VARCHAR(50), backgroundColor VARCHAR(50), separatorColor VARCHAR(50), nextButtonText VARCHAR(50), theme VARCHAR(100), previousButtonText VARCHAR(50), homeButtonText VARCHAR(50), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Reward (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), name VARCHAR(255), shortDescription VARCHAR(255), instructions VARCHAR(255), activation VARCHAR(255), completionCount INTEGER, repeat INTEGER, lastCompletionTime VARCHAR(255), actionPlan VARCHAR(255), ontology varchar(150), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Ringtone (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), fileURL VARCHAR(125), timeLength CHAR(10), fileSize CHAR(10), soundData blob, name varchar(100), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Role (objectID CHAR(40) NOT NULL PRIMARY KEY,creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,description VARCHAR(150), worldModel VARCHAR(255),name varchar(100), image blob, hierarchy varchar(150), ontology varchar(150))",
                              @"CREATE TABLE RoleApplication (roleID char(40) NOT NULL,roleHierarchy varchar(150),applicationID CHAR(40) NOT NULL,objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)",
                              @"CREATE TABLE Rule (objectID CHAR(40) NOT NULL PRIMARY KEY,creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,description VARCHAR(150), worldModel VARCHAR(255),type char(10),ruleText varchar(200),name VARCHAR(100),category CHAR(40),active integer NOT NULL DEFAULT 0)",
							  @"CREATE TABLE ScheduleEvent (objectID CHAR(40) NOT NULL PRIMARY KEY,creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,description VARCHAR(150), worldModel VARCHAR(255),dayInWeekOfStudy integer, event varchar(150),hourOfDayStudy integer,weekOfStudy integer)",
                              @"CREATE TABLE Security (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), password VARCHAR(255), endPointURL VARCHAR(255), endPointPort VARCHAR(10), securityCertificate blob, enforceSecurity smallint DEFAULT 0, encryption smallint DEFAULT 0, encryptionKey varchar(255), userName VARCHAR(255), adminUserName VARCHAR(255), adminPassword VARCHAR(255), vendor VARCHAR(255), securityToken VARCHAR(255), clientIdentifier VARCHAR(255), clientSecretKey VARCHAR(255), PRIMARY KEY (objectID))",
							  @"CREATE TABLE Session (organizationID char(40),sessionID char(40),active INTEGER NOT NULL DEFAULT 0,investigator CHAR(40),referredBy CHAR(40),startTime DATETIME,sessionType VARCHAR(50),objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,endTime DATETIME,category varchar(100),duration char(40) NOT NULL DEFAULT \"unlimited\")",
                              @"CREATE TABLE SessionDataType (objectID CHAR(40) NOT NULL PRIMARY KEY,creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,description VARCHAR(150), worldModel VARCHAR(255),lookup VARCHAR(25),title VARCHAR(25),category CHAR(40))",
                              @"CREATE TABLE SessionPatient (sessionID char(40) NOT NULL, patientID CHAR(40) NOT NULL, objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
                              @"CREATE TABLE SessionStudy (sessionID char(40) NOT NULL, studyID CHAR(40) NOT NULL, objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
							  @"CREATE TABLE Site (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), ontology varchar(150), name VARCHAR(255), administrator VARCHAR(125), buildingId VARCHAR(100), address VARCHAR(255), city VARCHAR(255), stateOrProvince VARCHAR(100), zip VARCHAR(100), country VARCHAR(100), PRIMARY KEY (objectID))",
							  @"CREATE TABLE Study (organizationID char(40),studyID char(40),calibrated INTEGER NOT NULL DEFAULT 0,investigator CHAR(40),referredBy CHAR(40),studyType VARCHAR(50),lamportDayClock INTEGER,lamportHourClock INTEGER,lamportWeekClock INTEGER,msStartDate DOUBLE,useLogicalClock INTEGER,appVersion VARCHAR(10),clinicalPathwayAuthor VARCHAR(60),clinicalPathwayVersion VARCHAR(10),startDate VARCHAR(20),studyDuration VARCHAR(10),studyEmailFrom VARCHAR(120),studyEmailLogin VARCHAR(120),studyEmailPass VARCHAR(120),studyEmailPort VARCHAR(10),studyEmailSMTP VARCHAR(120),studyEmailSubject VARCHAR(200),studyEmailTo VARCHAR(120),studyName VARCHAR(200),studyPrimaryResearcher VARCHAR(120),studySecondaryResearcher VARCHAR(120), var1 VARCHAR(50), var2 VARCHAR(50), var3 VARCHAR(50), objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255), studySite VARCHAR(120), studyPrimaryLanguage VARCHAR(120), creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP)",
                              @"CREATE TABLE Task (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), name VARCHAR(255), shortDescription VARCHAR(255), instructions VARCHAR(255), activation VARCHAR(255), completionCount INTEGER, repeat INTEGER, priority VARCHAR(255), status varchar(255), lastCompletionTime VARCHAR(255), actionPlan VARCHAR(255), ontology varchar(150), code varchar(150), PRIMARY KEY (objectID))",
                              @"CREATE TABLE Timer (name varchar(50),active INTEGER NOT NULL DEFAULT 0,startTime DATETIME,objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,category varchar(100),sound char(40), repeat char(40), message varchar(200), startTimeTerse char(20))",
                              @"CREATE TABLE TimerRepeat (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), name varchar(100), PRIMARY KEY (objectID))",
                              @"CREATE TABLE User (lastName VARCHAR(50),firstName VARCHAR(50),userNum CHAR(40),gender CHAR(1),weight CHAR(4),height CHAR(4),objectID CHAR(40) NOT NULL PRIMARY KEY DEFAULT \"unknown\",description VARCHAR(150), worldModel VARCHAR(255),creationTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,deviceToken VARCHAR(70),role VARCHAR(255))",
                              @"CREATE TABLE UserApplication (userID char(40) NOT NULL, applicationID CHAR(40) NOT NULL, objectID CHAR(40) DEFAULT \"unknown\" NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
                              @"CREATE TABLE UserRole (userID char(40) NOT NULL, roleID CHAR(40) NOT NULL, objectID CHAR(40) NOT NULL, description VARCHAR(150), worldModel VARCHAR(255), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,PRIMARY KEY (objectID))",
							  @"CREATE INDEX i1 ON Activity (relatedID, sysID, reason)",
							  @"CREATE INDEX i2 ON Activity (relatedID, reason, locationCode)",
							  @"CREATE INDEX i3 ON Asset (patientID)",
						      @"CREATE INDEX i4 ON Asset (archived)",
						      @"CREATE INDEX i5 ON Asset (assetArchived)",
                              nil
                             ];
	
	for (NSString* command in schemaCommands) {
		[self execute:command error:&err];
		
		if (err != nil) {
			return;
		}
	}
}

- (void) checkForSchemaUpdates:(int)dbSchemaVersion {
   	char*  errorPointer;

    switch (dbSchemaVersion) {
        case 0: {
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Asset ADD COLUMN archived smallint DEFAULT 0;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Asset ADD COLUMN assetArchived smallint DEFAULT 0;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Asset ADD COLUMN worldModel VARCHAR(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Asset ADD COLUMN container VARCHAR(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "CREATE INDEX i3 ON Asset (patientID);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "CREATE INDEX i4 ON Asset (archived);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "CREATE INDEX i5 ON Asset (assetArchived);", NULL, NULL, &errorPointer);
						
            //  TODO: Remove, Left over from code for version 0 schema where the archive flag was inadvertently set on all MedTrack objects whether archived or not.
            ActivityDAO* dao = [ActivityDAO new];
            [dao updateAllUnArchive];

			//  TODO: Remove, Left over from code for version 0 schema where the patient ID was set to null for MedTrack 'Talk To Us' assets.
			AssetDAO* assetDao = [AssetDAO new];
			[assetDao updateNullPatientId];
		}
		case 1: {
			sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "CREATE TABLE Security (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), password VARCHAR(255), endPointURL VARCHAR(255), endPointPort VARCHAR(10), securityCertificate blob, enforceSecurity smallint DEFAULT 0, encryption smallint DEFAULT 0, encryptionKey varchar(255), PRIMARY KEY (objectID));", NULL, NULL, &errorPointer);
        }
		case 2: {
      		sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE ProtocolHistory ADD COLUMN relatedID CHAR(40);", NULL, NULL, &errorPointer);
		}
        case 3: {
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN rewardPoints CHAR(20);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN points CHAR(20);", NULL, NULL, &errorPointer);
        }
        case 4: {
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Activity ADD COLUMN goalID CHAR(40);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Activity ADD COLUMN taskID CHAR(40);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Activity ADD COLUMN rewardID CHAR(40);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Goal ADD COLUMN completionTime CHAR(40);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN photo blob;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN photo2 blob;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN photo3 blob;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN coachFilePath CHAR(120);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "CREATE TABLE RenderStyle (objectID CHAR(40) NOT NULL, description VARCHAR(150), creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, textColor VARCHAR(50), textFontSize VARCHAR(50), textFontFamily VARCHAR(50), questionColor VARCHAR(50), questionFontSize VARCHAR(50), questionFontFamily VARCHAR(50), headerColor VARCHAR(50), headerFontSize VARCHAR(50), headerFontFamily VARCHAR(50), choiceTextColor VARCHAR(50), choiceFontSize VARCHAR(50), choiceFontFamily VARCHAR(50), responseBorderColor VARCHAR(50), backgroundColor VARCHAR(50), separatorColor VARCHAR(50), nextButtonText VARCHAR(50), previousButtonText VARCHAR(50), homeButtonText VARCHAR(50), theme VARCHAR(100), PRIMARY KEY (objectID));", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "CREATE TABLE Features (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), eula VARCHAR(255), hasEula smallint DEFAULT 0, splashScreen blob, hasLoginScreen smallint DEFAULT 1, hasReminders smallint DEFAULT 0, PRIMARY KEY (objectID));", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN welcomeCoach smallint;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Study ADD COLUMN studySite VARCHAR(120);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Study ADD COLUMN studyPrimaryLanguage VARCHAR(120);", NULL, NULL, &errorPointer);
        }
        case 5: {
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Goal ADD COLUMN code CHAR(150);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN coachPhoto1 blob;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Patient ADD COLUMN coachPhoto2 blob;", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Security ADD COLUMN userName VARCHAR(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Security ADD COLUMN securityToken VARCHAR(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Security ADD COLUMN clientIdentifier VARCHAR(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Security ADD COLUMN clientSecretKey VARCHAR(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Task ADD COLUMN code VARCHAR(150);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Timer ADD COLUMN startTimeTerse CHAR(20);", NULL, NULL, &errorPointer);
        }
        case 6: {
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Goal ADD COLUMN startTime varchar(40);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Security ADD COLUMN adminUserName varchar(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Security ADD COLUMN adminPassword varchar(255);", NULL, NULL, &errorPointer);
            sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE Security ADD COLUMN vendor varchar(255);", NULL, NULL, &errorPointer);
			sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "ALTER TABLE User ADD COLUMN role varchar(255);", NULL, NULL, &errorPointer);
			sqlite3_exec([[WSResourceManager sharedResourceManager] getConnection], "CREATE TABLE Site (objectID CHAR(40) NOT NULL, creationTime DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, description VARCHAR(150), ontology varchar(150), name VARCHAR(255), administrator VARCHAR(125), buildingId VARCHAR(100), address VARCHAR(255), city VARCHAR(255), stateOrProvince VARCHAR(100), zip VARCHAR(100), country VARCHAR(100), PRIMARY KEY (objectID));", NULL, NULL, &errorPointer);
        }
	}
}

@end
