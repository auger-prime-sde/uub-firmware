#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) 
{
  FILE *input_file;
  int secondsu, delta_ticsu;
  int i,j,status;
  int saturated, baseline, peak, area;
  int buf[6];

  if (argc != 2)
    {
      printf("Usage: convert_file input_filename\n"); 
      exit(0);
    } 
 
  input_file = fopen(argv[1],"r");
  if (input_file == 0) {
    printf("Unable to open input file\n");
    return 1;
  }

  while(1)
    {
      // Print time of event
      status = fread(&secondsu, sizeof(int), 1, input_file);
      if (status != 1) break;
      fread(&delta_ticsu, sizeof(int), 1, input_file);

      printf("\n>>>>>>>>>> BEGINNING OF EVENT HEADER >>>>>>>>>>\n");
      printf("%8x %8x\n",secondsu, delta_ticsu);

      // Print FPGA calculated quantities
      for (i=0; i<10; i++)
        {
          fread(&j, sizeof(int), 1, input_file);
          fread(&saturated, sizeof(int), 1, input_file);
          fread(&baseline, sizeof(int), 1, input_file);
          fread(&peak, sizeof(int), 1, input_file);
          fread(&area, sizeof(int), 1, input_file);
        }
          
      printf("%1d %1d %4d %4d %d\n", 
             j, saturated, baseline, peak, area);
      printf("<<<<<<<<<< END OF EVENT HEADER <<<<<<<<<<\n");
	
      printf("\n>>>>>>>>>> BEGINNING OF EVENT >>>>>>>>>>\n");

      for (i=0; i<2048; i++)
        {
          fread(&j, sizeof(int), 1, input_file);
          fread(&buf[0], sizeof(int), 6, input_file);
	  printf("%3x %8x %8x %8x %8x %8x\n",
		 i, (int)buf[0], (int)buf[1], (int)buf[2],
		 (int)buf[3], (int)buf[4]); 
        }
      printf("<<<<<<<<<< END OF EVENT <<<<<<<<<<\n\n");
    }         
  fclose(input_file);
  return 0;
}
