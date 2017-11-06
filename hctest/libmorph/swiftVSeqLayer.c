//
//  swiftVSeqLayer.c
//  HopliteChallenge
//
//  Created by Jeremy March on 11/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//
#include <stdlib.h>
#include "swiftVSeqLayer.h"

VerbSeqOptions swiftLayerOptions;

void setOptions()
{
    swiftLayerOptions.startOnFirstSing = true;
}

void externalSetUnits(const char *unitStr)
{
    int i = 0;
    char *end = (char *) unitStr;
    while (*end && i < 20)
    {
        long unitNum = strtol(unitStr, &end, 10);
        
        swiftLayerOptions.units[i] = (int) unitNum;
        //printf("%ld\n", iUnits[i]);
        i++;
        while (*end == ',')
        {
            end++;
        }
        unitStr = end;
    }
    swiftLayerOptions.numUnits = i;
}

int nextVS(int *seq, VerbFormD *vf1, VerbFormD *vf2)
{
    int a = nextVerbSeq2(vf1, vf2, &swiftLayerOptions);
    *seq = swiftLayerOptions.verbSeq;
    //fprintf(stdout, "SWIFT LAYER\n\n");
    return a;
}

bool checkVFResult(UCS2 *expected, int expectedLen, UCS2 *entered, int enteredLen, bool MFPressed, const char *elapsedTime, int *score, int *lives)
{
    bool a = compareFormsCheckMFRecordResult(expected, expectedLen, entered, enteredLen, MFPressed, elapsedTime, &swiftLayerOptions);
    
    *lives = swiftLayerOptions.lives;
    *score = swiftLayerOptions.score;
    
    return a;
}

void swiftResetVerbSeq()
{
    swiftLayerOptions.isHCGame = false;
    swiftLayerOptions.startOnFirstSing = false;
    swiftLayerOptions.degreesToChange = 2;
    swiftLayerOptions.practiceVerbID = 3;
    
    externalSetUnits("2");
    
    resetVerbSeq(&swiftLayerOptions);
}
