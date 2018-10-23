//
//  specialverbs.h
//  HopliteChallenge
//
//  Created by Jeremy March on 9/11/18.
//  Copyright © 2018 Jeremy March. All rights reserved.
//

#ifndef specialverbs_h
#define specialverbs_h

#include <stdio.h>
#include "libmorph.h"
#include "GreekUnicode.h"

int getEimi(VerbFormC *vf, UCS2 *buffer, int *bufferLen, int bufferCapacity);
int getOida(VerbFormC *vf, UCS2 *buffer, int *bufferLen, int bufferCapacity, bool decompose);
int getXrh(VerbFormC *vf, UCS2 *buffer, int *bufferLen, int bufferCapacity, bool decompose);
int getDei(VerbFormC *vf, UCS2 *buffer, int *bufferLen, int bufferCapacity, bool decompose);

#endif /* specialverbs_h */
