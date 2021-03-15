#include "shwr_evt_defs.h"
#include <stdio.h>
#include "read_evt.h" /*the read_evt -> are the real implementation
			of read the event. It is done in this way
			to make easier possible different implementation,
			keeping only the main logic to the main code.
			The read_evt use global variables to handle
			the different data structure needed, but the
			interface would be exactly the same for
			all the implementations.
		      */

//main()
FeShwrRead_test() {
	int aux;
	struct shwr_evt_raw evt;
	int nevts, i, j, index;

	aux = read_evt_init();
	if (aux != 0) {
		printf(
				"FeShwrRead: Problem in start the Front-End - (shower read) %d \n",
				aux);
		return (0);
	}

	nevts = 0;
	printf("Starts the main loop\n");
	while (nevts < 30) {
		while (read_evt_read(&evt) != 0)
			; /*wait for a available event */
		nevts++;
		printf("# nevts: %d; type1: %08x ; type2: %08x %d\n", nevts,
				evt.Evt_type_1, evt.Evt_type_2, evt.id);
		for (j = 0; j < SHWR_NSAMPLES; j++) {
			index = (j + evt.trace_start) % SHWR_NSAMPLES;
			printf("%4d %4d  ", j, index);
			for (i = 0; i < SHWR_RAW_NCH_MAX; i++) {
				printf("%4d %4d ", evt.fadc_raw[i][index] & 0xFFF,
						(evt.fadc_raw[i][index] >> 16) & 0xFFF);
			}
			printf("%d \n", (evt.fadc_raw[4][index] >> 28) & 0xF);
		}
		printf("\n");
	}
	read_evt_end();
}
