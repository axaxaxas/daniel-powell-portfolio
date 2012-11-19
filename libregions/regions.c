/* This software is distributed under the GNU Lesser General Public License.
  *  See the root of this repository for details.
  *  Copyright 2012 Daniel Powell 
*/

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "regions.h"

#define coords_to_offset(DIM, X, Y, Z) Z + (Y * DIM) + (X * DIM * DIM)

Region* new_region(int dim) {
  /* Returns a pointer to a new Region structure.
	 
	 int dim => cubical dimension of the region
  */
  Region* ret;
  if (ret = malloc(sizeof(Region))) {
	ret->list = NULL; // the list is initially empty
	ret->dim = dim;
	return ret;
  } else {
	return NULL; // Return NULL if we failed to allocate memory.
  }
}

Bytemap* new_bytemap(int dim) {
  /* Returns a pointer to a new Bytemap structure.

	 int dim => cubical dimension of the bytemap
  */
  Bytemap* map;
  if (map = malloc(sizeof(Bytemap))) {
	map->dim = dim;
	map->bytecount = dim*dim*dim;
	map->bytes = malloc(map->bytecount);
	for (int i = 0; i < map->bytecount; i++) {
	  map->bytes[i] = 0x00;
	}
	return map;
  } else {
	return NULL; // Return NULL if we failed to allocate memory.
  }
}

int add_invpoint(int x, int y, int z, Region* reg) {
  /* Creates a new InversionList entry and adds it to a region.

	 int x, y, z => coordinates of the new point
	 Region* reg => pointer to a region to modify

	 Returns 0 on success and 1 on failure.
  */
  InversionList* newpoint;
  if (newpoint = malloc(sizeof(InversionList))) {
	newpoint->x = x;
	newpoint->y = y;
	newpoint->z = z;
	newpoint->next = reg->list;
	reg->list = newpoint;
	return 0; // success
  } else {
	return 1; // unable to allocate memory
  }
}

static inline void offset_to_coords(int dim, long offset, int* coordmem) {
  /* Calculates the coordinates of a point in a cubical 3D array, given
	 the linear offset of an element in that array. Outputs coordinates
	 in-place at a provided memory location.

	 int dim       => cubical dimension of the array
	 long offset   => offset of desired element
	 int* coordmem => pointer to allocated memory which will hold the result
  
	 ASSERT: coordmem points to at least sizeof(int)*3 contiguous bytes of
	         allocated memory
  */ 
  coordmem[2] = offset % dim;
  coordmem[1] = ((offset - coordmem[2])/dim) % dim;
  coordmem[0] = ((offset - coordmem[1] - coordmem[2])/(dim*dim)) % dim;
}

void apply_invpoint(Bytemap* map, InversionList* list, char toggle) {
  /* Modifies a Bytemap by toggling specified bits in each byte
	 forward of a given inversion point.

	 Bytemap* map        => pointer to a bytemap to be modified
	 InversionList* list => pointer to an inversion list. the first and only the
	                        first point in the list will be applied
	 char toggle         => byte specifying which bits to toggle
  */
  for (int x = list->x; x < map->dim; x++) {
    for (int y = list->y; y < map->dim; y++) {
      for (int z = list->z; z < map->dim; z++) {
		map->bytes[coords_to_offset(map->dim, x, y, z)] ^= toggle;
      }
    }
  }
}

void apply_invlist(Bytemap* map, InversionList* list, char toggle) {
  /* Modifies a Bytemap by toggling specified bits in each byte
	 for each inversion point in a list.

	 Bytemap* map        => pointer to a bytemap to be modified
	 InversionList* list => pointer to an inversion list to apply
	 char toggle         => byte specifying which bits to toggle
  */
  while (list != NULL) {
	apply_invpoint(map, list, toggle);
	list = list->next;
  }
}

char get_state(int x, int y, int z, InversionList* list) {
  /* Determines whether a specified point is currently 
	 a member of the set defined by a given inversion list.

	 int x, y, z         => 3d coordinates of point to test
	 InversionList list  => an inversion list to test against

	 Returns either an all-on byte or an all-off byte to indicate
	 membership or non-membership, respectively.

	 The test is performed by allocating a byte to serve as a
	 return value, then walking through the list and toggling
	 the byte for each applicable inversion point.
  */
  char state = 0x00;
  while (list != NULL) {
	if ((x >= list->x) && (y >= list->y) && (z >= list->z)) {
	  state ^= 0xFF;
	}
	list = list->next;
  }
  return state;
}

Region* map_to_region(Bytemap* map, char mask) {
  /* Returns a new region corresponding to the subset
	 of a given bytemap which is nonzero under a
	 given mask.

	 Bytemap* map => bytemap to base the new region on
	 char mask    => a byte to mask each element of the map against
  */
  Region* reg;
  if (reg = calloc(1, sizeof(Region))) { // reg->list will be NULL since calloc pre-initializes to 0
	reg->dim = map->dim;
	for (int x = 0; x < map->dim; x++) {
	  for (int y = 0; y < map->dim; y++) {
		for (int z = 0; z < map->dim; z++) {
		  
		  if ((map->bytes[coords_to_offset(map->dim, x, y, z)] && mask) != (get_state(x, y, z, reg->list) && mask)) {
			// The left-hand side of this inequality will be identical to the mask only if the on bits 
			// in the mask are also on in the bytemap element under consideration. Otherwise, it will be zero.
			//
			// The right-hand of the inequality will be identical to the mask only if (x, y, z) is 
			// currently a member of the region's set, since get_state returns 0xFF only in that case. 
			// In all other cases, get_state will return 0, and so the right-hand side will be equal to 0.
			//
			// So, the inequality will be true only if the region does not correspond to the map; we can
			// change this by adding the point under consideration to the region's inversion list:

			add_invpoint(x, y, z, reg);

			// Adding this point will change the membership of more points in the region than the one
			// currently under consideration. But these points are exactly those points which are equal to
			// or greater than the current point in all three dimensions. Because we're iterating from
			// 0 to map->dim, none of these points have yet been considered, and so will be toggled
			// back if necessary in a future iteration.
		  }
		}
	  }
	}
	return reg;
  } else {
	return NULL; // return NULL if we failed to allocate memory
  }
}

