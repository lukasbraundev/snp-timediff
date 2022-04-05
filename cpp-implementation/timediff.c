#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
// #include <sys/time.h>
#include <assert.h>
#include <unistd.h>

// function prototypes
extern void list_init(void);
extern short list_size(void);
extern bool list_is_sorted(void);
extern short list_add(struct timeval *tv);
extern short list_find(struct timeval *tv);
extern bool list_get(struct timeval *tv, short idx);

int main(void)
{
    printf("Main\n");

    // test imports
    list_init();
    list_size();
    list_is_sorted();
    list_add(NULL);
    list_find(NULL);
    list_get(NULL, NULL);

    // get the input from stdin
    int bufferSize =
        10000 // max number of timestamps
        * 64  // max bit size of timestamp
        / 8;  // bits -> bytes

    char buffer[bufferSize];
    read(STDIN_FILENO, buffer, bufferSize);

    // get the actual size of the input
    int inputSize = strlen(buffer);

    char **parts = malloc(sizeof(char *) * inputSize);
    int partCount = 0;

    // parse the input
    for (int i = 0; i < inputSize; i++) {
        printf("%c", buffer[i]);

        if (buffer[i] == "\r") {
            // skip
        } else {

            if (buffer[i] == '\n') {
                parts[partCount] = malloc(sizeof(char) * i);
                memcpy(parts[partCount], buffer, i);
                parts[partCount][i] = '\0';
                partCount++;
                i = 0;
            }

        }
    }
    printf("\n");

    return 0;
}