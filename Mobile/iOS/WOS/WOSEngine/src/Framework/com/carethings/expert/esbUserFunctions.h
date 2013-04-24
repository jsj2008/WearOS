/*!
 *  @file Interaction.h
 *
 *  @details	Represents an interaction (utterance) within the wStack framework.
 *			When used in an agent-based environment, represents an utterance between agents. Multiple utterances are required to represent a conversation.
 *
 *  @Author	Larry Suarez
 *  @package com.carethings.domain
 *
 *  Copyright (c) 2011, CareThings, Inc.
 *  All rights reserved.
 *
 * This code  is the  sole  property of the University of California,
 * San Francisco (UCSF), and is protected by copyright under the laws of
 * the United States. This program is confidential, proprietary, and a trade
 * secret, not to be disclosed without written authorization from
 * UCSF.  Any  use, duplication, or  disclosure of this program  by other
 * than UCSF and its assigned licensees is strictly forbidden by law.
 */

#ifndef __ESBUSERFUNCTIONS__
#define __ESBUSERFUNCTIONS__


typedef struct ClipsRetStruct
{ 
    long           m_retCode;
    long           m_command;
    long           m_intParam1;
    long           m_intParam2;
    long           m_intParam3;
    long           m_intParam4;
    long           m_intParam5;
    long           m_intParam6;
    long           m_intParam7;
    long           m_intParam8;
    long           m_intParam9;
    long           m_intParam10;
    long           m_intParam11;
    long           m_intParam12;
    long           m_intParam13;
    long           m_intParam14;
    long           m_intParam15;

    char*          m_charParam1;
    char*          m_charParam2;
    char*          m_charParam3;
    char*          m_charParam4;
    char*          m_charParam5;

    double         m_floatParam1;
    double         m_floatParam2;
    double         m_floatParam3;

} ClipsRetStruct;


#ifdef __cplusplus
extern "C" {
#endif

void QueryResultsStruct( void*);   //  CLIPs data returned via a structure - ClipsRetStruct
void QueryResultsXML( void*);      //  CLIPs data returned via an XML document.
void PublishFact( void*);          //  CLIPs command to publish a fact to the data store.

#ifdef __cplusplus
}
#endif


#endif