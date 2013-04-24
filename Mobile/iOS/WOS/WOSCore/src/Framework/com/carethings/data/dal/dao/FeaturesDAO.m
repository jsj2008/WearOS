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

#import "FeaturesDAO.h"
#import "WSResourceManager.h"
#import "ResdbResult.h"
#import "StringUtils.h"

@implementation FeaturesDAO

- (id)allocateDaoObject {
    return [Features new];
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow {
    char*  textPtr = nil;

    Features* features = (Features*)daoObject;

    if ((features == nil) || (sqlRow == nil))
        return;

    int i = 0;
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        features.objectID = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        features.creationTime = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        features.description = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        features.version = [NSString stringWithUTF8String:textPtr];
    if ((textPtr = (char*)sqlite3_column_text(sqlRow,i++)))
        features.eula = [NSString stringWithUTF8String:textPtr];
    features.hasEula = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasSocial = (bool) sqlite3_column_int(sqlRow,i++);
    features.socialParticipantToProvider = (bool) sqlite3_column_int(sqlRow,i++);
    features.socialProviderToParticipant = (bool) sqlite3_column_int(sqlRow,i++);
    features.socialParticipantToParticipant = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasSplashScreen = (bool) sqlite3_column_int(sqlRow,i++);
    features.serviceSOPDrugInformation = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasProgress = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasReminders = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasInformation = (bool) sqlite3_column_int(sqlRow,i++);
     if (sqlite3_column_bytes(sqlRow,i) > 0)
        features.informationXMLProtocol = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
    i++;
    if (sqlite3_column_bytes(sqlRow,i) > 0)
        features.splashScreen = [NSMutableData dataWithBytes:sqlite3_column_blob(sqlRow, i) length:(NSUInteger) sqlite3_column_bytes(sqlRow, i)];
    i++;
    features.hasAuthentication = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasSensors = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasAlerts = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasGoals = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasActivities = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasRewards = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasBehaviorPatterns = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasGeozones = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasBehaviors = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasTheme = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasGaming = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettings = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettingAlarm = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettingAuthentication = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettingResearcher = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettingSite = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettingGeozone = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettingParticipantId = (bool) sqlite3_column_int(sqlRow,i++);
    features.requireSettingUserName = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasVisitedSettings = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasPhases = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasVirtualCoach = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasLanguages = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasDesktopPhoto = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasResearcherLanguage = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasParticipantIDSettings = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasUserNameSettings = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasResearcherSettings = (bool) sqlite3_column_int(sqlRow,i++);
    features.hasSiteSettings = (bool) sqlite3_column_int(sqlRow,i++);
}

- (ResdbResult*)retrieve:(NSString*)objectID {
    NSString *      sql    = @"select objectID, creationTime, description, version, eula, hasEula, hasSocial, socialParticipantToProvider, socialProviderToParticipant, socialParticipantToParticipant, hasSplashScreen, serviceSOPDrugInformation, hasProgress, hasReminders, hasInformation, informationXMLProtocol, splashScreen, hasAuthentication, hasSensors, hasAlerts, hasGoals, hasActivities, hasRewards, hasBehaviorPatterns, hasGeozones, hasBehaviors, hasTheme, hasGaming, requireSettings, requireSettingAlarm, requireSettingAuthentication, requireSettingResearcher, requireSettingSite, requireSettingGeozone, requireSettingParticipantId, requireSettingUserName, hasVisitedSettings, hasPhases, hasVirtualCoach, hasLanguages, hasDesktopPhoto, hasResearcherLanguage, hasParticipantIDSettings, hasUserNameSettings, hasResearcherSettings, hasSiteSettings from Features where objectID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self findSingleRow:sql withParams:params];
}

- (ResdbResult*)retrieveByRelatedId:(NSString*)relatedID {
     NSString *      sql    = @"select objectID, creationTime, description, version, eula, hasEula, hasSocial, socialParticipantToProvider, socialProviderToParticipant, socialParticipantToParticipant, hasSplashScreen, serviceSOPDrugInformation, hasProgress, hasReminders, hasInformation, informationXMLProtocol, splashScreen, hasAuthentication, hasSensors, hasAlerts, hasGoals, hasActivities, hasRewards, hasBehaviorPatterns, hasGeozones, hasBehaviors, hasTheme, hasGaming, requireSettings, requireSettingAlarm, requireSettingAuthentication, requireSettingResearcher, requireSettingSite, requireSettingGeozone, requireSettingParticipantId, requireSettingUserName, hasVisitedSettings,hasPhases, hasVirtualCoach, hasLanguages, hasDesktopPhoto, hasResearcherLanguage, hasParticipantIDSettings, hasUserNameSettings, hasResearcherSettings, hasSiteSettings from Features where relatedID=?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self findMultiRow:sql withParams:params];
}

- (ResdbResult*)retrieveAll {
     NSString *      sql    = @"select objectID, creationTime, description, version, eula, hasEula, hasSocial, socialParticipantToProvider, socialProviderToParticipant, socialParticipantToParticipant, hasSplashScreen, serviceSOPDrugInformation, hasProgress, hasReminders, hasInformation, informationXMLProtocol, splashScreen, hasAuthentication, hasSensors, hasAlerts, hasGoals, hasActivities, hasRewards, hasBehaviorPatterns, hasGeozones, hasBehaviors, hasTheme, hasGaming, requireSettings, requireSettingAlarm, requireSettingAuthentication, requireSettingResearcher, requireSettingSite, requireSettingGeozone, requireSettingParticipantId, requireSettingUserName, hasVisitedSettings, hasPhases, hasVirtualCoach, hasLanguages, hasDesktopPhoto, hasResearcherLanguage, hasParticipantIDSettings, hasUserNameSettings, hasResearcherSettings, hasSiteSettings from Features";

    return [self findMultiRow:sql withParams:nil];
}

- (ResdbResult*)insert:(Features*)features {
   NSString *      sql    = @"INSERT into Features (objectID, description, version, eula, hasEula, hasSocial, socialParticipantToProvider, socialProviderToParticipant, socialParticipantToParticipant, hasSplashScreen, serviceSOPDrugInformation, hasProgress, hasReminders, hasInformation, informationXMLProtocol, splashScreen, hasAuthentication, hasSensors, hasAlerts, hasGoals, hasActivities, hasRewards, hasBehaviorPatterns, hasGeozones, hasBehaviors, hasTheme, hasGaming, requireSettings,requireSettingAlarm, requireSettingAuthentication, requireSettingResearcher, requireSettingSite, requireSettingGeozone, requireSettingParticipantId, requireSettingUserName, hasVisitedSettings, hasPhases, hasVirtualCoach, hasLanguages, hasDesktopPhoto, hasResearcherLanguage, hasParticipantIDSettings, hasUserNameSettings, hasResearcherSettings, hasSiteSettings) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
   NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:features.objectID] ? [NSNull null] : features.objectID),
                                                              ([StringUtils isEmpty:features.description] ? [NSNull null] : features.description),
                                                              ([StringUtils isEmpty:features.version] ? [NSNull null] : features.version),
                                                              ([StringUtils isEmpty:features.eula] ? [NSNull null] : features.eula),
                                                              [[NSNumber alloc] initWithInt:features.hasEula],
                                                              [[NSNumber alloc] initWithInt:features.hasSocial],
                                                              [[NSNumber alloc] initWithInt:features.socialParticipantToProvider],
                                                              [[NSNumber alloc] initWithInt:features.socialProviderToParticipant],
                                                              [[NSNumber alloc] initWithInt:features.socialParticipantToParticipant],
                                                              [[NSNumber alloc] initWithInt:features.hasSplashScreen],
                                                              [[NSNumber alloc] initWithInt:features.serviceSOPDrugInformation],
                                                              [[NSNumber alloc] initWithInt:features.hasProgress],
                                                              [[NSNumber alloc] initWithInt:features.hasReminders],
                                                              [[NSNumber alloc] initWithInt:features.hasInformation],
                                                              ((features.informationXMLProtocol == nil) ?  [NSNull null] : features.informationXMLProtocol),
                                                              ((features.splashScreen == nil) ?  [NSNull null] : features.splashScreen),
                                                              [[NSNumber alloc] initWithInt:features.hasAuthentication],
                                                              [[NSNumber alloc] initWithInt:features.hasSensors],
                                                              [[NSNumber alloc] initWithInt:features.hasAlerts],
                                                              [[NSNumber alloc] initWithInt:features.hasGoals],
                                                              [[NSNumber alloc] initWithInt:features.hasActivities],
                                                              [[NSNumber alloc] initWithInt:features.hasRewards],
                                                              [[NSNumber alloc] initWithInt:features.hasBehaviorPatterns],
                                                              [[NSNumber alloc] initWithInt:features.hasGeozones],
                                                              [[NSNumber alloc] initWithInt:features.hasBehaviors],
                                                              [[NSNumber alloc] initWithInt:features.hasTheme],
                                                              [[NSNumber alloc] initWithInt:features.hasGaming],
                                                              [[NSNumber alloc] initWithInt:features.requireSettings],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingAlarm],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingAuthentication],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingResearcher],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingSite],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingGeozone],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingParticipantId],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingUserName],
                                                              [[NSNumber alloc] initWithInt:features.hasVisitedSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasPhases],
                                                              [[NSNumber alloc] initWithInt:features.hasVirtualCoach],
                                                              [[NSNumber alloc] initWithInt:features.hasLanguages],
                                                              [[NSNumber alloc] initWithInt:features.hasDesktopPhoto],
                                                              [[NSNumber alloc] initWithInt:features.hasResearcherLanguage],
                                                              [[NSNumber alloc] initWithInt:features.hasParticipantIDSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasUserNameSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasResearcherSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasSiteSettings], nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)update:(Features*)features {
     NSString *      sql    = @"UPDATE Features SET objectID = ?, description = ?, version = ?, eula = ?, hasEula = ?, hasSocial = ?, socialParticipantToProvider = ?, socialProviderToParticipant = ?, socialParticipantToParticipant = ?, hasSplashScreen = ?, serviceSOPDrugInformation = ?, hasProgress = ?, hasReminders = ?, hasInformation = ?, informationXMLProtocol = ?, splashScreen = ?, hasAuthentication = ?, hasSensors = ?, hasAlerts = ?, hasGoals = ?, hasActivities = ?, hasRewards = ?, hasBehaviorPatterns = ?, hasGeozones = ?, hasBehaviors = ?, hasTheme = ?, hasGaming = ?, requireSettings = ?,requireSettingAlarm = ?, requireSettingAuthentication = ?, requireSettingResearcher = ?, requireSettingSite = ?, requireSettingGeozone = ?, requireSettingParticipantId = ?, requireSettingUserName = ?, hasVisitedSettings = ?, hasPhases = ?, hasVirtualCoach = ?, hasLanguages = ?, hasDesktopPhoto = ?, hasResearcherLanguage = ?, hasParticipantIDSettings = ?, hasUserNameSettings = ?, hasResearcherSettings = ?, hasSiteSettings = ? WHERE objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:features.objectID] ? [NSNull null] : features.objectID),
                                                              ([StringUtils isEmpty:features.description] ? [NSNull null] : features.description),
                                                              ([StringUtils isEmpty:features.version] ? [NSNull null] : features.version),
                                                              ([StringUtils isEmpty:features.eula] ? [NSNull null] : features.eula),
                                                              [[NSNumber alloc] initWithInt:features.hasEula],
                                                              [[NSNumber alloc] initWithInt:features.hasSocial],
                                                              [[NSNumber alloc] initWithInt:features.socialParticipantToProvider],
                                                              [[NSNumber alloc] initWithInt:features.socialProviderToParticipant],
                                                              [[NSNumber alloc] initWithInt:features.socialParticipantToParticipant],
                                                              [[NSNumber alloc] initWithInt:features.hasSplashScreen],
                                                              [[NSNumber alloc] initWithInt:features.serviceSOPDrugInformation],
                                                              [[NSNumber alloc] initWithInt:features.hasProgress],
                                                              [[NSNumber alloc] initWithInt:features.hasReminders],
                                                              [[NSNumber alloc] initWithInt:features.hasInformation],
                                                              ((features.informationXMLProtocol == nil) ?  [NSNull null] : features.informationXMLProtocol),
                                                              ((features.splashScreen == nil) ?  [NSNull null] : features.splashScreen),
                                                              [[NSNumber alloc] initWithInt:features.hasAuthentication],
                                                              [[NSNumber alloc] initWithInt:features.hasSensors],
                                                              [[NSNumber alloc] initWithInt:features.hasAlerts],
                                                              [[NSNumber alloc] initWithInt:features.hasGoals],
                                                              [[NSNumber alloc] initWithInt:features.hasActivities],
                                                              [[NSNumber alloc] initWithInt:features.hasRewards],
                                                              [[NSNumber alloc] initWithInt:features.hasBehaviorPatterns],
                                                              [[NSNumber alloc] initWithInt:features.hasGeozones],
                                                              [[NSNumber alloc] initWithInt:features.hasBehaviors],
                                                              [[NSNumber alloc] initWithInt:features.hasTheme],
                                                              [[NSNumber alloc] initWithInt:features.hasGaming],
                                                              [[NSNumber alloc] initWithInt:features.requireSettings],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingAlarm],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingAuthentication],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingResearcher],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingSite],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingGeozone],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingParticipantId],
                                                              [[NSNumber alloc] initWithInt:features.requireSettingUserName],
                                                              [[NSNumber alloc] initWithInt:features.hasVisitedSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasPhases],
                                                              [[NSNumber alloc] initWithInt:features.hasVirtualCoach],
                                                              [[NSNumber alloc] initWithInt:features.hasLanguages],
                                                              [[NSNumber alloc] initWithInt:features.hasDesktopPhoto],
                                                              [[NSNumber alloc] initWithInt:features.hasResearcherLanguage],
                                                              [[NSNumber alloc] initWithInt:features.hasParticipantIDSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasUserNameSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasResearcherSettings],
                                                              [[NSNumber alloc] initWithInt:features.hasSiteSettings],
                                                              ([StringUtils isEmpty:features.objectID] ? [NSNull null] : features.objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}


- (ResdbResult*)deleteAll {
    NSString *      sql    = @"delete from Features";

    return [self insertUpdateDeleteRow:sql withParams:nil];
}

- (ResdbResult*)deleteByRelatedId:(NSString*)relatedID {
    NSString *      sql    = @"delete from Features where relatedID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:relatedID] ? [NSNull null] : relatedID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

- (ResdbResult*)delete:(NSString*)objectID {
    NSString *      sql    = @"delete from Features where objectID = ?";
    NSMutableArray* params = [NSMutableArray arrayWithObjects:([StringUtils isEmpty:objectID] ? [NSNull null] : objectID), nil];

    return [self insertUpdateDeleteRow:sql withParams:params];
}

@end