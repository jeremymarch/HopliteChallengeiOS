//
//  augment.h
//  Hoplite Challenge
//
//  Created by Jeremy March on 3/4/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//

#ifndef augment_h
#define augment_h

#include <stdio.h>
#include <stdbool.h>
#include "utilities.h"
#include "libmorph.h"
#include "GreekUnicode.h"

void augmentStem(VerbFormC *vf, UCS2 *ucs2, int *len, int bufferCapacity, bool decompose, int stem);

void stripAugmentFromPrincipalPart(VerbFormC *vf, UCS2 *ucs2, int *len, int bufferCapacity, UCS2 presentStemInitial, bool decompose);

void decomposePrefixes(VerbFormC *vf, UCS2 *ucs2, int *len, int bufferCapacity);

#endif /* augment_h */
