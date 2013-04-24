// @&# esbUserFunctions.c 1.1 Copyright (C) 1993 AgentNet, Inc   */
//
// This code  is the  sole  property  of  AgentNet  Corporation,
// and is protected  by  copyright  under the  laws of the United     
// States. This program is confidential, proprietary, and a trade
// secret, not to be disclosed without written authorization from     
// AgentNet Corporation.  Any  use, duplication, or  disclosure 
// of  this  program  by other than AgentNet Corporation and its 
// assigned licensees is strictly forbidden by law. 
//
// File:
//		esbUserFunctions.c
//
// Description:
//		User-Defined Functions used by the Agent Grid Expert System. Contains two
//      routines for returning data from CLIPs.  One routine returns data via a well-known
//      structure in which data is returned by ordinal position (i.e. the first returned data from
//      CLIPs is returned in the first structure field). The second routine is much more general
//      and returns data by name in an XML document.  However, returning via XML is much slower than
//      returning via a structure.
//
// Revision History                                                          
// ----------------
//
// $History:     $ 
//
// #&@ 
//
#include <esbUserFunctions.h>
#include <clips.h>


/* @&#  1.1 Copyright (C) 1998 Agent Net, Inc  
 *
 * Function:
 *		QueryResultsStruct()	
 *
 * Description:
 *		Constructs an ClipsRetStruct structure to hold the contents of data returned
 *      from Clips.  Provides a way for those invoking a Clips command to
 *      examine data returned from the command.  Data is returned by ordinal position (i.e.
 *      first returned integer data is returned in structure member 'm_intParam1').  This is a
 *      fairly fast routine.
 *
 * Parameters:
 *
 *
 * Returns:
 *
 *
 * Revision History                                                          
 * ----------------
 *
 * $History:     $ 
 *
 * #&@ 
 */
void QueryResultsStruct( void*  env)
{
	long				argCount = EnvRtnArgCount( env);
	DATA_OBJECT			param;
	long				i;
	long				intCount = 0;
	long				floatCount = 0;
	long				strCount = 0;
	long				paramType;
	long				agentId;
	ClipsRetStruct*		statusp = NULL;
	char*				strRetp = NULL;
	int					strLength = 0;


	//
	//  The agent identifier and the status struct pointer are both
	//  required.
	//
	if (argCount < 2)
		return;

	agentId = EnvRtnLong( env, 1);
	statusp = (ClipsRetStruct*)(long)EnvRtnLong( env, 2);

	//
	//  Start walking the parameters and filling up the status
	//  object.  The caller is assumed to know how to process
	//  the parameters.
	//
	for (i = 3; i <= argCount; i++)
	{
		EnvRtnUnknown( env, i, &param);

		if (!param.value)
			continue;

		paramType = EnvGetType( env, param);

		if (paramType == INTEGER)
		{
			intCount++;

			switch (intCount)
			{
				case 1:
					statusp->m_intParam1 = EnvDOToInteger( env, param);
					break;

				case 2:
					statusp->m_intParam2 = EnvDOToInteger( env, param);
					break;

				case 3:
					statusp->m_intParam3 = EnvDOToInteger( env, param);
					break;

				case 4:
					statusp->m_intParam4 = EnvDOToInteger( env, param);
					break;

				case 5:
					statusp->m_intParam5 = EnvDOToInteger( env, param);
					break;

				case 6:
					statusp->m_intParam6 = EnvDOToInteger( env, param);
					break;

				case 7:
					statusp->m_intParam7 = EnvDOToInteger( env, param);
					break;

				case 8:
					statusp->m_intParam8 = EnvDOToInteger( env, param);
					break;

				case 9:
					statusp->m_intParam9 = EnvDOToInteger( env, param);
					break;

				case 10:
					statusp->m_intParam10 = EnvDOToInteger( env, param);
					break;

				case 11:
					statusp->m_intParam11 = EnvDOToInteger( env, param);
					break;

				case 12:
					statusp->m_intParam12 = EnvDOToInteger( env, param);
					break;

				case 13:
					statusp->m_intParam13 = EnvDOToInteger( env, param);
					break;

				case 14:
					statusp->m_intParam14 = EnvDOToInteger( env, param);
					break;

				case 15:
					statusp->m_intParam15 = EnvDOToInteger( env, param);
					break;
			}
		}
		else if ((paramType == STRING) || (paramType == SYMBOL))
		{
			strCount++;

			//
			//  Save the string off for the caller.  We have a problem of
			//  malloc'ing the string within the DLL since it can't be released
			//  by the caller.  Think about this.
			//
			strLength = strlen( EnvDOToString( env, param)) + 1;

			if (strLength > 0)
			{
				strRetp = malloc( strLength);
				memset( strRetp, '\0', strLength);
				memcpy( strRetp, EnvDOToString( env, param), strLength);

				switch (strCount)
				{
					case 1:
						statusp->m_charParam1 = strRetp;
						break;

					case 2:
						statusp->m_charParam2 = strRetp;
						break;

					case 3:
						statusp->m_charParam3 = strRetp;
						break;

					case 4:
						statusp->m_charParam4 = strRetp;
						break;

					case 5:
						statusp->m_charParam5 = strRetp;
						break;
				}
			}
		}
		else if (paramType == FLOAT)
		{
			floatCount++;

			switch (floatCount)
			{
				case 1:
					statusp->m_floatParam1 = EnvDOToFloat( env, param);
					break;

				case 2:
					statusp->m_floatParam2 = EnvDOToFloat( env, param);
					break;

				case 3:
					statusp->m_floatParam3 = EnvDOToFloat( env, param);
					break;
			}
		}
	}
}


/* @&#  1.1 Copyright (C) 1998 Agent Net, Inc  
 *
 * Function:
 *		QueryResultsXML()	
 *
 * Description:
 *		Constructs an XML Document to hold the contents of data returned
 *      from Clips.  Provides a way for those invoking a Clips command to
 *      examine data returned from the command.  Data is returned by name.  This
 *      is a fairly slow routine.
 *
 * Parameters:
 *
 *
 * Returns:
 *
 *
 * Revision History                                                          
 * ----------------
 *
 * $History:     $ 
 *
 * #&@ 
 */
void QueryResultsXML( void* env)
{
	long				argCount = EnvRtnArgCount( env);
	DATA_OBJECT			param;
	long				i;
	long				agentId;
	char**				xmlVarDocp = NULL;
	char*               xmlBuff = malloc(50000);
	char*               xmlBuffp = xmlBuff;
	int                 continueDoc = FALSE;


	//
	//  The agent identifier and a char pointer-to-pointer are both
	//  required.
	//
	if (argCount < 2)
		return;

	agentId = EnvRtnLong( env, 1);
	xmlVarDocp = (char**)(long)EnvRtnLong( env, 2);

	if (!xmlVarDocp)
		return;

	//
	//  We need to determine if we are being called because of another
	//  fact firing the same rule.  This typically happens when an agent sends another
	//  agent a collection of data.  We need to represent the entire collection in one
	//  XML document.
	//
	if (*xmlVarDocp)
		continueDoc = TRUE;

	//
	//  We should be using XML routines to construct the
	//  document but we don't have a C version as of yet (only C++).
	//  So construct by hand.  Our documents are very simple.
	//
	memset( xmlBuffp, '\0', 50000);

	if (!continueDoc)
	{
		sprintf( xmlBuffp, "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>");
		xmlBuffp = xmlBuff + strlen( xmlBuff);

		//
		//  Add the daplet marker.
		//
		sprintf( xmlBuffp, "<AgentNetVarDoc>");
		xmlBuffp = xmlBuff + strlen( xmlBuff);
	}

	sprintf( xmlBuffp, "<Record>");
	xmlBuffp = xmlBuff + strlen( xmlBuff);

	//
	//  Start walking the parameters and constructing the XML
	//  nodes.
	//
	for (i = 3; i <= argCount; i++)
	{
		EnvRtnUnknown( env, i, &param);

		if (!param.value)
			continue;

		//
		//  Start a Datum.
		//
		sprintf( xmlBuffp, "<Datum name=\"%s\"><Name>%s</Name>", ((char*)param.supplementalInfo)+1, ((char*)param.supplementalInfo)+1);
		xmlBuffp = xmlBuff + strlen( xmlBuff);

		//
		//  Create the Type node.  We are hardcoding the AgentNet value for types (e.g. ESB_PRES_DTYPE_INTEGER).
		//  This is going to bite somebody in the butt someday when the value changes and the system
		//  no longer works.
		//
		switch (param.type)
		{
			case INTEGER:
				sprintf( xmlBuffp, "<Type>2022</Type>");
				xmlBuffp = xmlBuff + strlen( xmlBuff);

				//
				//  Add the value itself.
				//
				sprintf( xmlBuffp, "<Value>%i</Value>", EnvDOToInteger( env, param));
				xmlBuffp = xmlBuff + strlen( xmlBuff);
				break;

			case STRING:
			case SYMBOL:
				sprintf( xmlBuffp, "<Type>2025</Type>");
				xmlBuffp = xmlBuff + strlen( xmlBuff);

				//
				//  Add the value itself.  Since the string may contain special characters (e.g. Java code
				//  or HTML code), we place the string in a CDATA section.
				//
				sprintf( xmlBuffp, "<Value><![CDATA[%s]]></Value>", EnvDOToString( env, param));
				xmlBuffp = xmlBuff + strlen( xmlBuff);
				break;

			case FLOAT:
				sprintf( xmlBuffp, "<Type>2021</Type>");
				xmlBuffp = xmlBuff + strlen( xmlBuff);

				//
				//  Add the value itself.
				//
				sprintf( xmlBuffp, "<Value>%f</Value>", EnvDOToFloat( env, param));
				xmlBuffp = xmlBuff + strlen( xmlBuff);
				break;
		}

		//
		//  Finish off the datum.
		//
		sprintf( xmlBuffp, "</Datum>");
		xmlBuffp = xmlBuff + strlen( xmlBuff);
	}

	//
	//  Finish off the record.
	//
	sprintf( xmlBuffp, "</Record>");
	xmlBuffp = xmlBuff + strlen( xmlBuff);

	//
	//  Do not finish off the document.  This routine will be called for each fact that 
	//  satisfies the rule so we may be called numerous times.  The caller is responsible for
	//  closing off the document since they know when the rule firings are exhausted.
	//

	if (continueDoc)
	{
		char*  xmlVarp = *xmlVarDocp;

		xmlVarp += strlen( *xmlVarDocp);

		sprintf( xmlVarp, "%s", xmlBuff);
	}
	else
		*xmlVarDocp = xmlBuff;
}


/* @&#  1.1 Copyright (C) 1998 Agent Net, Inc  
 *
 * Function:
 *		PublishFact()	
 *
 * Description:
 *		Function to publish a fact for a behavior.
 *
 * Parameters:
 *
 *
 * Returns:
 *
 *
 * Revision History                                                          
 * ----------------
 *
 * $History:     $ 
 *
 * #&@ 
 */
void PublishFact( void* env)
{
	long				argCount = EnvRtnArgCount( env);
	DATA_OBJECT			param;
	char**				strRetpp = NULL;
	char*			    theStringp = malloc(2000);


	//
	//  The agent identifier and a char pointer-to-pointer are both
	//  required.
	//
	if (argCount < 2)
		return;

	//
	//  Process the first argument which is the fact address.
	//
	EnvRtnUnknown( env, 1, &param);

	if (param.type == FACT_ADDRESS)
	{
		char*			theStrRouter = "*** print-to-string ***";


		memset( theStringp, '\0', 2000);

		//
		// Initialize string router 
		//
		if (!OpenStringDestination( env, theStrRouter, theStringp, 2000))
			return;

		//PrintFact( env, theStrRouter, theFact);
	}
	else
	{
		free( theStringp);
		return;
	}

	//
	//  Process the second argument which is the return string address.
	//
	strRetpp = (char**)(long)EnvRtnLong( env, 2);

	if (!strRetpp)
	{
		free( theStringp);
		return;
	}

	*strRetpp = theStringp;
}
