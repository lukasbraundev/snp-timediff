#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
// #include <sys/time.h>
#include <assert.h>

void list_init(void) {
    printf("list_init()\n");
}


short list_size(void) {
    printf("list_size()\n");
    
    return 0;
}


bool list_is_sorted(void) {
    printf("list_is_sorted()\n");
    
    return false;
}


short list_add(struct timeval *tv) {
    printf("list_add()\n");
    
    return 0;
}


short list_find(struct timeval *tv) {
    printf("list_find()\n");
    
    return 0;
}


bool list_get(struct timeval *tv, short idx) {
    printf("list_get()\n");
    
    return false;
}


