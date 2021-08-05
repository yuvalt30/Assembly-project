#include <stdio.h>
#include "pstring.h"


void run_main() {

	Pstring p1;
	Pstring p2;
	int len;
	int opt;

	printf("enter int, str, int, str \n");
	// initialize first pstring
	scanf("%d", &len);
	scanf("%s", p1.str);
	p1.len = len;

	// initialize second pstring
	scanf("%d", &len);
	scanf("%s", p2.str);
	p2.len = len;

	printf("enter opt: \n");
	// select which function to run
	scanf("%d", &opt);
	run_func(opt, &p1, &p2);

}


// char pstrlen(Pstring* pstr) {
// 	return pstr->len;
// }

// Pstring* replaceChar(Pstring* pstr, char oldChar, char newChar) {
// 	for (int i=0; i< pstr->len; i++) {
// 			if (pstr->str[i] == oldChar) {
// 				pstr->str[i] = newChar;
// 		}
// 	}
// 	return pstr;
// }

// Pstring* pstrijcpy(Pstring* dst, Pstring* src, char i, char j) {
// 	if(j >= dst->len || j >= src->len) {
// 		printf("invalid input!\n");
// 		return dst;
// 	}
// 	while (i <= j) {
// 		dst->str[i] = src->str[i];
// 		i++;
// 	}
// 	return dst;
// }

// Pstring* swapCase(Pstring* pstr) {
// 	int i = 0;
// 	while (i < pstr->len) {
// 		if (pstr->str[i] < 'z' && pstr->str[i] > 'a') {
// 			pstr->str[i] -= 32;
// 			i++;
// 			continue;
// 		}
// 		if (pstr->str[i] < 'Z' && pstr->str[i] > 'A') {
// 			pstr->str[i] += 32;
// 		}
// 		i++;
// 	}
// 	return pstr;
// }

// int pstrijcmp(Pstring* p1, Pstring* p2, char i, char j) {
// 	if(j >= p1->len || j >= p2->len) {
//  		printf("invalid input!\n");
// 		 return -2;
// 	}
// 	while(i <= j) {
// 		if (p1->str[i] != p2->str[i]) {
// 			if (p1->str[i] > p2->str[i]) {
// 				return 1;
// 			} else {
// 				return -1;
// 			}
// 		}
// 		i++;
// 	}
// 	return 0;
// }