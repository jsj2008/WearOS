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

#import "ResdbObject.h"


@interface Features : ResdbObject {
    NSString*       version;
    NSString*       eula;
    bool            hasEula;
    bool            hasSocial;
    bool            socialParticipantToProvider;
    bool            socialProviderToParticipant;
    bool            socialParticipantToParticipant;
    bool            hasSplashScreen;
    bool            serviceSOPDrugInformation;
    bool            hasProgress;
    bool            hasReminders;
    bool            hasInformation;
    NSMutableData*  informationXMLProtocol;
    NSMutableData*  splashScreen;
    bool            hasAuthentication;
    bool            hasSensors;
    bool            hasAlerts;
    bool            hasGoals;
    bool            hasActivities;
    bool            hasRewards;
    bool            hasBehaviorPatterns;
    bool            hasGeozones;
    bool            hasBehaviors;
    bool            hasTheme;
    bool            hasGaming;
    bool            hasPhases;
    bool            hasVirtualCoach;
    bool            hasLanguages;
    bool            hasDesktopPhoto;
    bool            hasResearcherLanguage;
    bool            hasParticipantIDSettings;
    bool            hasUserNameSettings;
    bool            hasResearcherSettings;
    bool            hasSiteSettings;
    bool            hasVisitedSettings;
    bool            requireSettings;
    bool            requireSettingAlarm;
    bool            requireSettingAuthentication;
    bool            requireSettingResearcher;
    bool            requireSettingSite;
    bool            requireSettingGeozone;
    bool            requireSettingParticipantId;
    bool            requireSettingUserName;
}

@property(nonatomic, copy) NSString *version;
@property(nonatomic, copy) NSString *eula;
@property(nonatomic) bool hasEula;
@property(nonatomic) bool hasSocial;
@property(nonatomic) bool socialParticipantToProvider;
@property(nonatomic) bool socialProviderToParticipant;
@property(nonatomic) bool socialParticipantToParticipant;
@property(nonatomic) bool hasSplashScreen;
@property(nonatomic) bool serviceSOPDrugInformation;
@property(nonatomic) bool hasProgress;
@property(nonatomic) bool hasReminders;
@property(nonatomic) bool hasInformation;
@property(nonatomic, strong) NSMutableData *informationXMLProtocol;
@property(nonatomic, strong) NSMutableData *splashScreen;
@property(nonatomic) bool hasAuthentication;
@property(nonatomic) bool hasSensors;
@property(nonatomic) bool hasAlerts;
@property(nonatomic) bool hasGoals;
@property(nonatomic) bool hasActivities;
@property(nonatomic) bool hasRewards;
@property(nonatomic) bool hasBehaviorPatterns;
@property(nonatomic) bool hasGeozones;
@property(nonatomic) bool hasBehaviors;
@property(nonatomic) bool hasTheme;
@property(nonatomic) bool hasGaming;
@property(nonatomic) bool hasPhases;
@property(nonatomic) bool hasVirtualCoach;
@property(nonatomic) bool hasLanguages;
@property(nonatomic) bool hasDesktopPhoto;
@property(nonatomic) bool hasResearcherLanguage;
@property(nonatomic) bool hasParticipantIDSettings;
@property(nonatomic) bool hasUserNameSettings;
@property(nonatomic) bool hasResearcherSettings;
@property(nonatomic) bool hasSiteSettings;
@property(nonatomic) bool hasVisitedSettings;
@property(nonatomic) bool requireSettings;
@property(nonatomic) bool requireSettingAlarm;
@property(nonatomic) bool requireSettingAuthentication;
@property(nonatomic) bool requireSettingResearcher;
@property(nonatomic) bool requireSettingSite;
@property(nonatomic) bool requireSettingGeozone;
@property(nonatomic) bool requireSettingParticipantId;
@property(nonatomic) bool requireSettingUserName;

@end