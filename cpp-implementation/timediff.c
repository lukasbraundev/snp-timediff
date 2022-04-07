#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include <sys/time.h>
#include <assert.h>
#include <sys/types.h>
#include <unistd.h>

// gcc timediff.c list.c -o exe.out; cat testinput | ./exe.out

// function prototypes
extern void list_init(void);
extern short list_size(void);
extern bool list_is_sorted(void);
extern short list_add(struct timeval *tv);
extern short list_find(struct timeval *tv);
extern bool list_get(struct timeval *tv, short idx);

int main(void) {

  // printf("Main\n");

  // get the input from stdin
  int bufferSize = 10000 // max number of timestamps
                   * 64  // max bit size of timestamp
                   / 8;  // bits -> bytes

  char buffer[bufferSize];
  read(STDIN_FILENO, buffer, bufferSize);

  // get the actual size of the input
  int inputSize = strlen(buffer) + 1;

  // get rid of every \r
  char inputText[inputSize];
  int inputIndex = 0;
  for (int bufferIndex = 0; bufferIndex < inputSize; bufferIndex++) {
    if (buffer[bufferIndex] != '\r') {
      inputText[inputIndex] = buffer[bufferIndex];
      inputIndex++;
    }
  }
  inputSize = strlen(inputText);

  // parse the input
  char inputParts[20000][10];
  int partCount = 0;
  int charCount = 0;
  for (int i = 0; i < inputSize; i++) {
    if (inputText[i] == '\n' || inputText[i] == '.') {
      partCount++;
      charCount = 0;
      // printf("break!at: %c\n", inputText[i]);
    } else {
      inputParts[partCount][charCount] = inputText[i];
      charCount++;
      // printf("charCount: %d char: %c\n", charCount, inputText[i]);
    }
  }

  // parse string parts to timevals
  struct timeval timestamps[10000];
  int timestampIdx = 0;
  char currentString[10];
  for (int i = 0; i < partCount; i++) {
    for (int j = 0; j < 10; j++) {
      currentString[j] = ' ';
      currentString[j] = inputParts[i][j];
    }
    
    timestampIdx = (i / 2);

    if (i % 2 == 0) {
      // printf("adding tv_sec\n");
      timestamps[timestampIdx].tv_sec = atoi(currentString);
    } else {
      // printf("adding tv_usec\n");
      timestamps[timestampIdx].tv_usec = atoi(currentString);
    }
  }
  int quantityOfTimestamps = timestampIdx + 1;

  // check if list is sorted
  int isSorted = 0; // true
  for (int i = 1; i < quantityOfTimestamps; i++) {
    long previousMS = (timestamps[i-1].tv_sec * 1000000) + timestamps[i-1].tv_usec;
    long currentMS = (timestamps[i].tv_sec * 1000000) + timestamps[i].tv_usec;
    if (previousMS > currentMS) isSorted = 1;
  }

  // if not sorted interrupt
  if (isSorted == 1) {
    printf("Error: is not sorted!");
    return 1;
  }

  // create difference strings
  char differenceStrings[quantityOfTimestamps-1][100];
  printf("%ld.%06d\n", timestamps[0].tv_sec, timestamps[0].tv_usec);
  for (int i = 1; i < quantityOfTimestamps; i++) {
    long previousMS = (timestamps[i-1].tv_sec * 1000000) + timestamps[i-1].tv_usec;
    long currentMS = (timestamps[i].tv_sec * 1000000) + timestamps[i].tv_usec;
    long diffMS = currentMS - previousMS;
    
    long MS_PER_DAY = 86400000000;
    long MS_PER_H = 3600000000;
    long MS_PER_M = 60000000;
    long MS_PER_S = 1000000;

    long diffDays = diffMS / MS_PER_DAY; diffMS = diffMS % MS_PER_DAY;
    long diffHours = diffMS / MS_PER_H; diffMS = diffMS % MS_PER_H;
    long diffMinutes = diffMS / MS_PER_M; diffMS = diffMS % MS_PER_M;
    long diffSeconds = diffMS / MS_PER_S; diffMS = diffMS % MS_PER_S;

    // print out the calculated values

    printf("=======\n");
    printf("%ld.%06d\n", timestamps[i].tv_sec, timestamps[i].tv_usec);

    // check if display the date is necessary
    if (diffDays > 0) printf("%ld days, ", diffDays);
    printf("%02ld:%02ld:%02ld.%06ld\n", diffHours, diffMinutes, diffSeconds, diffMS);

  }

  return 0;
}