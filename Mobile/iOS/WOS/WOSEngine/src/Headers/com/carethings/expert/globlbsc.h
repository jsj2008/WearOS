/*******************************************************/
/*      "C" Language Integrated Production System      */
/*                                                     */
/*             CLIPS Version 6.24  06/05/06            */
/*                                                     */
/*         DEFGLOBAL BASIC COMMANDS HEADER FILE        */
/*******************************************************/

/*************************************************************/
/* Purpose:                                                  */
/* Principal Programmer(s):                                  */
/*      Gary D. Riley                                        */
/*                                                           */
/* Contributing Programmer(s):                               */
/*      Brian L. Dantes                                      */
/*                                                           */
/* Revision History:                                         */
/*      6.23: Corrected compilation errors for files         */
/*            generated by constructs-to-c. DR0861           */
/*                                                           */
/*      6.24: Renamed BOOLEAN macro type to intBool.         */
/*                                                           */
/*************************************************************/

#ifndef _H_globlbsc
#define _H_globlbsc

#ifndef _H_evaluatn
#include "evaluatn.h"
#endif

#ifdef LOCALE
#undef LOCALE
#endif

#ifdef _GLOBLBSC_SOURCE_
#define LOCALE
#else
#define LOCALE extern
#endif

#define GetDefglobalList(a, b) EnvGetDefglobalList(GetCurrentEnvironment(), a, b)
#define GetDefglobalWatch(a) EnvGetDefglobalWatch(GetCurrentEnvironment(), a)
#define ListDefglobals(a, b) EnvListDefglobals(GetCurrentEnvironment(), a, b)
#define SetDefglobalWatch(a, b) EnvSetDefglobalWatch(GetCurrentEnvironment(), a, b)
#define Undefglobal(a) EnvUndefglobal(GetCurrentEnvironment(), a)

LOCALE void                           DefglobalBasicCommands(void*);
LOCALE void                           UndefglobalCommand(void*);
LOCALE intBool                        EnvUndefglobal(void*, void*);

LOCALE void GetDefglobalListFunction(void*, DATA_OBJECT_PTR);
LOCALE void EnvGetDefglobalList(void*, DATA_OBJECT_PTR, void*);
LOCALE void* DefglobalModuleFunction(void*);
LOCALE void                           PPDefglobalCommand(void*);
LOCALE int                            PPDefglobal(void*, char*, char*);
LOCALE void                           ListDefglobalsCommand(void*);
LOCALE void                           EnvListDefglobals(void*, char*, void*);
LOCALE unsigned                       EnvGetDefglobalWatch(void*, void*);
LOCALE void                           EnvSetDefglobalWatch(void*, unsigned, void*);
LOCALE void                           ResetDefglobals(void*);

#ifndef _GLOBLBSC_SOURCE_
extern unsigned WatchGlobals;
#endif

#endif