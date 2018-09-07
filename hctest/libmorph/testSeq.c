/*
Use:
gcc -std=c99 ../testSeq.c ../libmorph.c ../GreekForms.c ../accent.c ../utilities.c ../augment.c ../ending.c ../VerbSequence.c -I.. -o testSeq
./checkVerbForms2
diff -u 2017-03-23_19-23-18.txt 2017-03-23_19-25-58.txt
*/
#include <time.h>
#include <stdlib.h> // For random(), RAND_MAX
#include <string.h>  //for strlen
#include <stdbool.h> //for bool type
#include "libmorph.h"
#include "utilities.h"
#include "VerbSequence.h"
#include "sqlite3.h"

/*
typedef struct so {
    int numPerson;
    int numNumbers;
    int numTense;
    int numVoice;
    int numMood;
    int persons[3];
    int numbers[2];
    int tenses[5];
    int voices[3];
    int moods[4];
} SeqOptions;

typedef struct vso {
    bool startOnFirstSing;
    unsigned char repsPerVerb;
    unsigned char degreesToChange;
    unsigned char numUnits;
    bool askEndings;
    bool askPrincipalParts;
    bool isHCGame; //else is practice
    int practiceVerbID; //to just practice on one verb
    long gameId;
    int score;
    int lives;
    int verbSeq;
    bool firstVerbSeq;
    bool lastAnswerCorrect;
    int units[20];
    SeqOptions seqOptions;
} VerbSeqOptions;
*/

extern Verb verbs[];
extern char *tenses[];
extern char *moods[];
extern char *voices[];

int numVerbs = 125;

int main(int argc, char **argv)
{
    int rowCount = 0;
    int bufferLen = 50;
    char buffer[bufferLen];
    int bufferLen2 = 137;
    char buffer2[bufferLen2];

    VerbSeqOptions opt;
    opt.practiceVerbID = 1;

    opt.seqOptions.numPerson = 3;
    opt.seqOptions.numNumbers = 2;
    opt.seqOptions.numTense = 6;
    opt.seqOptions.numVoice = 3;
    opt.seqOptions.numMood = 3;
    opt.seqOptions.numVerbs = 2;

    memmove(opt.seqOptions.persons, (int[]){0,1,2}, opt.seqOptions.numPerson*sizeof(int));
    memmove(opt.seqOptions.numbers, (int[]){0,1}, opt.seqOptions.numNumbers*sizeof(int));
    memmove(opt.seqOptions.tenses, (int[]){0,1,2,3,4,5}, opt.seqOptions.numTense*sizeof(int));
    memmove(opt.seqOptions.voices, (int[]){0,1,2}, opt.seqOptions.numVoice*sizeof(int));
    memmove(opt.seqOptions.moods, (int[]){0,1,2}, opt.seqOptions.numMood*sizeof(int));
    memmove(opt.seqOptions.verbs, (int[]){1,2}, opt.seqOptions.numVerbs*sizeof(int));

    resetVerbSeq(&opt);

    //fprintf(stdout, "\nTotal rows including -: %d\n", rowCount);
}
