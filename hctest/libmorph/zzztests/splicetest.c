#include <stdlib.h> // For random(), RAND_MAX
#include <string.h>  //for strlen()
#include <stdbool.h> //for bool type
#include <stdio.h>

typedef uint16_t UCS2;

//1 2 3 4 5

#define DEBUG_SPLICE(X) debug_msg(X)

void debug_msg(char *x)
{
    fprintf(stderr, "%s\n", x);
    //exit(1);
}

bool rightShiftFromOffsetSteps2(UCS2 *ucs2, int offset, int steps, int *len, int buffer_len)
{
    if (*len + steps > buffer_len)
    {
          DEBUG_SPLICE("right shift: out of bounds!");
          return false;
    }
    if (offset >= *len)
    {
          DEBUG_SPLICE("right shift: offset out of bounds!");
          return false;
    }

    for (int j = *len ; j >= offset; j--)
    {
        //printf("j: %d\n", j);
        ucs2[j + steps] = ucs2[j];
        ucs2[j] = 0;
    }
    *len += steps;
    return true;
}

//Moves everything over to the left, eating the char at the offset index
bool leftShiftFromOffsetSteps2(UCS2 *ucs2, int offset, int steps, int *len)
{
    if (offset < 0)
    {
          DEBUG_SPLICE("offset out of bounds!");
          return false;
    }
    if (offset + steps > *len)
    {
          DEBUG_SPLICE("out of bounds!");
          return false;
    }
    int j = offset;
    for ( ; j < *len - 1; j++)
    {
        ucs2[j] = ucs2[j + steps];
    }
    *len -= steps;
    return true;
}

/*
* Almost just like the Javascript function splice
* Except there cannot be any empty gaps, it will fail
* string: the string
* len: the actual len of the string
* buffer_len: the length of the array buffer
* offset: the offset to begin inserting/removing elements
* replacing: how many characters to replace or remove if insert_len is 0
* insert: the string to insert
* insert_len: the length of the elements to be inserted.  Can be 0 if just want to remove.
*
* returns true, or false if error
*/
bool splice(UCS2 *string, int *len, int buffer_len, int offset, int replacing, UCS2 *insert, int insert_len)
{
  if (*len + insert_len - replacing > buffer_len)
  {
    DEBUG_SPLICE("out of bounds!");
    return false;
  }
  if (offset >= *len + 1)
  {
    DEBUG_SPLICE("offset beyond end of string + 1!"); //would create gap
    return false;
  }
  if (replacing > (*len - offset))
  {
    DEBUG_SPLICE("replacing cannot go past end of string!");
    return false;
  }
  if (insert_len < 0)
  {
    DEBUG_SPLICE("insert len must be >= 0!");
    return false;
  }
  if (offset > *len || offset < 0)
  {
      DEBUG_SPLICE("offset out of bounds!");
      return false;
  }
    //shift right, this function increases len
    if (replacing < insert_len)
    {
        if (offset + replacing < *len) //only call right shift if offset is before end, else rightShift will fail since nothing to move
        {
            if (!rightShiftFromOffsetSteps2(string, offset + replacing, insert_len - replacing, len, buffer_len))
            {
                return false;
            }
        }
        else
        {
            *len += insert_len;
        }
    }
    else if (replacing > insert_len)
    {
        if (!leftShiftFromOffsetSteps2(string, offset + replacing - 1, replacing - insert_len, len))
        {
            return false;
        }
    }
    for (int i = 0; i < insert_len; i++)
    {
      string[offset + i] = insert[i];
    }
  return true;
}

void printa(UCS2 *a, int n)
{
  for (int i = 0; i < n; i++)
  {
    printf("%d ", a[i]);
  }
}

bool test(UCS2 *a, UCS2 *b, int count)
{
    for (int i = 0; i < count; i++)
    {
        if (a[i] != b[i])
        {
            return false;
        }
    }
    return true;
}

int main(int argc, char **argv)
{
    int maxA = 8;
    int lenA = 5;
    UCS2 a[8] = {1,2,3,4,5,1,1,1};
    UCS2 clean[8] = {1,2,3,4,5,1,1,1};
    int lenB = 2;
    UCS2 b[4] = {5,6,7,8};

    //splice(a, &lenA, maxA, 0, 0, (UCS2[]){5,6,7,8}, 4); //overflow from beginning:  fail

printf("TEST 1: insert 3 at 0\n");
memmove(a, clean, sizeof(UCS2)*8);
lenA = 5;
printa(a, lenA);
    printf(" (len: %d)\n", lenA);
if (splice(a, &lenA, maxA, 0, 0, (UCS2[]){5,6,7,8}, 3) == false)
{
    printf("test failed\n");
    exit(1);
}
printa(a, lenA);
    printf(" (len: %d)\n", lenA);
if (!test(a, (UCS2[]){5,6,7,1,2,3,4,5}, 8))
{
    printf("test failed\n");
    exit(1);
}
else
{
    printf("test passed\n");
}

printf("TEST 2: insert 3 at 1\n");
memmove(a, clean, sizeof(UCS2)*8);
lenA = 5;
printa(a, lenA);
    printf(" (len: %d)\n", lenA);
if (splice(a, &lenA, maxA, 1, 0, (UCS2[]){5,6,7,8}, 3) == false)
{
    printf("test failed\n");
    exit(1);
}
printa(a, lenA);
    printf(" (len: %d)\n", lenA);
if (!test(a, (UCS2[]){1,5,6,7,2,3,4,5}, 8))
{
    printf("test failed\n");
    exit(1);
}
else
{
    printf("test passed\n");
}

    printf("TEST 3: insert 3 at 2\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 2, 0, (UCS2[]){5,6,7,8}, 3) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){1,2,5,6,7,3,4,5}, 8))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    printf("TEST 4: insert 3 at 4\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 4, 0, (UCS2[]){5,6,7,8}, 3) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){1,2,3,4,5,6,7,5}, 8))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    printf("TEST 5: insert 3 at 5\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 5, 0, (UCS2[]){5,6,7,8}, 3) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){1,2,3,4,5,5,6,7}, 8))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    printf("TEST 6: insert 3 at 4, replace 1\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 4, 1, (UCS2[]){5,6,7,8}, 3) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){1,2,3,4,5,6,7}, 7))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    printf("TEST 7: insert 3 at 0, replace 1\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 0, 1, (UCS2[]){5,6,7,8}, 3) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){5,6,7,2,3,4,5,6,7}, 7))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    printf("TEST 8: replace 1 at end\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, lenA - 1, 1, (UCS2[]){6,6,7,8}, 1) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){1,2,3,4,6}, 5))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    printf("TEST 9: remove 1 from beginning\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 0, 1, NULL, 0) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){2,3,4,5}, 4))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    printf("TEST 10: remove 1 from end\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 4, 1, NULL, 0) == false)
    {
        printf("test failed\n");
        exit(1);
    }
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (!test(a, (UCS2[]){1,2,3,4}, 4))
    {
        printf("test failed\n");
        exit(1);
    }
    else
    {
        printf("test passed\n");
    }

    //Tests meant to fail:
    printf("\nFail tests\n\n");

    printf("FAIL TEST 1: insert 4 at 0: fail\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 0, 0, (UCS2[]){5,6,7,8}, 4) == true)
    {
        printf("test failed\n");
        exit(1);
    }
    printf("test passed\n");

    printf("FAIL TEST 2: insert 4 at 4: fail\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 4, 0, (UCS2[]){5,6,7,8}, 4) == true)
    {
        printf("test failed\n");
        exit(1);
    }
    printf("test passed\n");

    printf("FAIL TEST 3: insert 4 at 5: fail\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 5, 0, (UCS2[]){5,6,7,8}, 4) == true)
    {
        printf("test failed\n");
        exit(1);
    }
    printf("test passed\n");

    printf("FAIL TEST 4: insert 2 at -1: fail\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, -1, 0, (UCS2[]){5,6,7,8}, 2) == true)
    {
        printf("test failed\n");
        exit(1);
    }
    printf("test passed\n");

    printf("FAIL TEST 5: insert 3 at 5, replace 1\n");
    memmove(a, clean, sizeof(UCS2)*8);
    lenA = 5;
    printa(a, lenA);
    printf(" (len: %d)\n", lenA);
    if (splice(a, &lenA, maxA, 5, 1, (UCS2[]){5,6,7,8}, 3) == true)
    {
        printf("test failed\n");
        exit(1);
    }
        printf("test passed\n");

        printf("FAIL TEST 6: insert 3 at 5, replace 1\n");
        memmove(a, clean, sizeof(UCS2)*8);
        lenA = 5;
        printa(a, lenA);
        printf(" (len: %d)\n", lenA);
        if (splice(a, &lenA, maxA, 5, 1, (UCS2[]){5,6,7,8}, 3) == true)
        {
            printf("test failed\n");
            exit(1);
        }
        printf("test passed\n\n");

        printf("All tests passed.\n");


}
