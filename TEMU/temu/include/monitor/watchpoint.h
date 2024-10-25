#ifndef __WATCHPOINT_H__
#define __WATCHPOINT_H__

#include "common.h"

typedef struct watchpoint {
	int NO;
	struct watchpoint *next;

	/* TODO: Add more members if necessary */

	char expr[32];
	uint32_t value;
} WP;

WP* get_head();
WP* new_wp();
void free_wp(WP *wp);
void print_wp_rcs(WP *wp);

#endif
