/*
 *  riskFactorFuncs.c
 *  mHealthOpenFramework
 *
 *  Created by Larry Suarez on 8/3/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "clips.h"

static int riskFactorCnt = 0;


void IncrRiskFactorCnt() {
	riskFactorCnt++;
};

int GetRiskFactorCnt() {
	return riskFactorCnt;
}

void InitRiskFactorCnt() {
	riskFactorCnt = 0;
}