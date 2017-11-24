//
//  swiftVSeqLayer.c
//  HopliteChallenge
//
//  Created by Jeremy March on 11/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//
#include <stdlib.h>
#include "swiftVSeqLayer.h"

VerbSeqOptions swiftLayerOptions; //this is the global options for the app.

void setOptions()
{
    swiftLayerOptions.startOnFirstSing = false;
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
    int a = nextVerbSeq(vf1, vf2, &swiftLayerOptions);
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
    swiftLayerOptions.isHCGame = true;
    //swiftLayerOptions.gameId = INSIPIENT
    swiftLayerOptions.startOnFirstSing = false;
    swiftLayerOptions.degreesToChange = 2;
    swiftLayerOptions.practiceVerbID = 3;
    
    swiftLayerOptions.seqOptions.persons[0] = 0;
    swiftLayerOptions.seqOptions.persons[1] = 1;
    swiftLayerOptions.seqOptions.persons[2] = 2;
    swiftLayerOptions.seqOptions.numbers[0] = 0;
    swiftLayerOptions.seqOptions.numbers[1] = 1;
    swiftLayerOptions.seqOptions.tenses[0] = 0;
    swiftLayerOptions.seqOptions.tenses[1] = 1;
    swiftLayerOptions.seqOptions.tenses[2] = 2;
    swiftLayerOptions.seqOptions.tenses[3] = 3;
    swiftLayerOptions.seqOptions.tenses[4] = 4;
    swiftLayerOptions.seqOptions.voices[0] = 0;
    swiftLayerOptions.seqOptions.voices[1] = 1;
    swiftLayerOptions.seqOptions.voices[2] = 2;
    swiftLayerOptions.seqOptions.moods[0] = 3;
    swiftLayerOptions.seqOptions.moods[1] = 1;
    swiftLayerOptions.seqOptions.moods[2] = 2;
    swiftLayerOptions.seqOptions.moods[3] = 3;
    swiftLayerOptions.seqOptions.numPerson = 3;
    swiftLayerOptions.seqOptions.numNumbers = 2;
    swiftLayerOptions.seqOptions.numTense = 5;
    swiftLayerOptions.seqOptions.numVoice = 3;
    swiftLayerOptions.seqOptions.numMood = 1;
    
    externalSetUnits("2");
    
    resetVerbSeq(&swiftLayerOptions);
}
