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

#import "MedStudyDebug.h"
#import "ResdbResult.h"
#import "WSKeyChainManager.h"
#import "WSPHRManager.h"
#import "WSResourceManager.h"

#import "ActivityDAO.h"
#import "AlertDAO.h"
#import "ApplicationDAO.h"
#import "AppStateDAO.h"
#import "AssetDAO.h"
#import "BehaviorDAO.h"
#import "CarePlanCaseDAO.h"
#import "CarePlanDAO.h"
#import "CasePatientDAO.h"
#import "CDPHProtocolHistoryDAO.h"
#import "DBSchemaVersionDAO.h"
#import "EventTypeDAO.h"
#import "FeaturesDAO.h"
#import "GeoPointDAO.h"
#import "GeozoneDAO.h"
#import "GoalDAO.h"
#import "GoalOntology.h"
#import "LogDAO.h"
#import "MemoDAO.h"
#import "ObjectDAO.h"
#import "PatientDAO.h"
#import "PatientRewardDAO.h"
#import "PhysicianNoteDAO.h"
#import "ProtocolHistoryDAO.h"
#import "ProviderDAO.h"
#import "ProviderPatientDAO.h"
#import "RenderStyleDAO.h"
#import "RewardDAO.h"
#import "RingtoneDAO.h"
#import "RoleApplicationDAO.h"
#import "RoleDAO.h"
#import "RuleDAO.h"
#import "ScheduleEventDAO.h"
#import "SecurityDAO.h"
#import "SessionDAO.h"
#import "SessionDataTypeDAO.h"
#import "SessionPatientDAO.h"
#import "SessionStudyDAO.h"
#import "SiteDAO.h"
#import "StudyDAO.h"
#import "TaskDAO.h"
#import "TimerDAO.h"
#import "TimerRepeatDAO.h"
#import "UserApplicationDAO.h"
#import "UserDAO.h"
#import "UserRoleDAO.h"

#import "Activity.h"
#import "Alert.h"
#import "Application.h"
#import "AppState.h"
#import "Asset.h"
#import "Behavior.h"
#import "CarePlanCase.h"
#import "CarePlan.h"
#import "CasePatient.h"
#import "CDPHProtocolHistory.h"
#import "ClinicReview.h"
#import "DBSchemaVersion.h"
#import "EventType.h"
#import "Features.h"
#import "GeoPoint.h"
#import "Geozone.h"
#import "Goal.h"
#import "GoalOntology.h"
#import "Log.h"
#import "Memo.h"
#import "Motif.h"
#import "Patient.h"
#import "PatientReward.h"
#import "PhysicianNote.h"
#import "ProtocolHistory.h"
#import "Provider.h"
#import "ProviderPatient.h"
#import "RenderStyle.h"
#import "ResdbObject.h"
#import "Reward.h"
#import "Ringtone.h"
#import "RoleApplication.h"
#import "Role.h"
#import "Rule.h"
#import "ScheduleEvent.h"
#import "Security.h"
#import "Session.h"
#import "SessionDataType.h"
#import "SessionPatient.h"
#import "SessionStudy.h"
#import "Site.h"
#import "Social.h"
#import "Study.h"
#import "Task.h"
#import "Timer.h"
#import "TimerRepeat.h"
#import "UserApplication.h"
#import "User.h"
#import "UserRole.h"
