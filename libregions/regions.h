/* This software is distributed under the GNU Lesser General Public License.
  *  See the root of this repository for details.
  *  Copyright 2012 Daniel Powell 
*/

#ifndef __regionsh   // idempotency
#define __regionsh 1

typedef struct InversionList InversionList;

struct InversionList {
	int x;
	int y;
	int z;
	InversionList* next;
};

typedef struct Region {
	int dim;
	InversionList* list;
} Region;

typedef struct Bytemap {
	int dim;
	int bytecount;
	char* bytes;
} Bytemap;

Region* new_region(int);
Bytemap* new_bytemap(int);

#ifdef __GNUC__
__attribute__((regparm(3))) // pass first three arguments in processor registers
#endif
int add_invpoint(int, int, int, Region*);

#ifdef __GNUC__
static inline void offset_to_coords(int, long, int*); // inline this function
#else
void offset_to_coords(int, long, int*);
#endif

void apply_invpoint(Bytemap*, InversionList*, char);
void apply_invlist(Bytemap*, InversionList*, char);
Region* map_to_region(Bytemap*, char);
char get_state(int, int, int, InversionList*);

#endif
