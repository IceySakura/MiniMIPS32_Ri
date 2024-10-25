#include "watchpoint.h"
#include "expr.h"
#include "cpu/reg.h"

#define NR_WP 32

static WP wp_pool[NR_WP];
static WP *head, *free_;

WP* get_head()
{
	return head;
}
void init_wp_pool() {
	int i;
	for(i = 0; i < NR_WP; i ++) {
		wp_pool[i].NO = i;
		wp_pool[i].next = &wp_pool[i + 1];
	}
	wp_pool[NR_WP - 1].next = NULL;

	head = NULL;
	free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

WP* new_wp()
{
	WP *wp = free_;
	if(wp == NULL)
	{
		printf("No enough watchpoint.\n");
		assert(0);
	}
	free_ = free_->next;
	wp->next = head;
	head = wp;
	return wp;
}

void free_wp(WP *wp)
{
	WP *p = head;
	if(p == wp)
	{
		head = head->next;
		wp->next = free_;
		free_ = wp;
		return;
	}
	while(p->next != NULL)
	{
		if(p->next == wp)
		{
			p->next = wp->next;
			wp->next = free_;
			free_ = wp;
			return;
		}
		p = p->next;
	}
	printf("Watchpoint not found.\n");
	assert(0);
}

void print_wp_rcs(WP *wp)
{
	if(wp == NULL)
	{
		return;
	}
	print_wp_rcs(wp->next);
	printf("%d\t%s\t0x%08x\n", wp->NO, wp->expr, wp->value);
}
