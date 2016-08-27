#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <fcntl.h>
#include <cuda.h>
#include "string.h"

#define DEFAULT_THRESHOLD 4000

#define DEFAULT_FILENAME "ansel3.ppm"

__global__ void sobel(unsigned int *ingoing, int *outgoing, int xsize, int ysize, int threshold) {

	 int x = threadIdx.x + (blockIdx.x * blockDim.x);
	 int y = threadIdx.y + (blockIdx.y * blockDim.y);

	 if ((x > 0) && (x < ysize - 1) &&(y > 0) &&  (y < xsize - 1)) {

		  int sum_x = ingoing[(x + 1) + ((y - 1) * ysize)]  -		ingoing[(x - 1) + ((y - 1) * ysize)]
				 + (2 * ingoing[(x + 1) + (		y * ysize)]) - (2 * ingoing[(x - 1) + (		y * ysize)])
						+ ingoing[(x + 1) + ((y + 1) * ysize)]  -		ingoing[(x - 1) + ((y + 1) * ysize)];

		  int sum_y = ingoing[(x + 1) + ((y + 1) * ysize)]  -		ingoing[(x + 1) + ((y - 1) * ysize)]
				 + (2 * ingoing[	  x  + ((y + 1) * ysize)]) - (2 * ingoing[		x + ((y - 1) * ysize)])
						+ ingoing[(x - 1) + ((y + 1) * ysize)]  -		ingoing[(x - 1) + ((y - 1) * ysize)];

		  
		  int magnitude = (sum_x * sum_x) + (sum_y * sum_y);
		  int i = x + (y * ysize);
		  if (magnitude > threshold) 
				outgoing[i] = 255;
		  

	 }
}

unsigned int *read_ppm(char *filename, int *xsize, int *ysize, int *maxval) {

	 if (!filename || filename[0] == '\0') {
		  fprintf(stderr, "read_ppm but no file name\n");
		  return NULL;
	 }

	 FILE *fp;

	 fprintf(stderr, "read_ppm(%s)\n", filename);
	 fp = fopen(filename, "rb");
	 if (!fp) {
		  fprintf(stderr, "read_ppm() ERROR file '%s' cannot be opened for reading\n", filename);
		  return NULL;
	 }

	 char chars[1024];
	 int num = fread(chars, sizeof(char), 1000, fp);

	 if (chars[0] != 'P' || chars[1] != '6') {
		  fprintf(stderr, "Texture::Texture() ERROR file '%s' does not start with \"P6\" I am expecting a binary PPM file\n", filename);
		  return NULL;
	 }

	 unsigned int width, height, maxvalue;

	 char *ptr = chars + 3; // P 6 newline
	 if (*ptr == '#') { // comment line!
		  ptr = 1 + strstr(ptr, "\n");
	 }

	 num = sscanf(ptr, "%d\n%d\n%d",  &width, &height, &maxvalue);
	 fprintf(stderr, "read %d things: width %d, height %d, maxval %d\n", num, width, height, maxvalue);
	 *xsize = width;
	 *ysize = height;
	 *maxval = maxvalue;

	 unsigned int *pic = (unsigned int *)malloc(width * height * sizeof(unsigned int));
	 if (!pic) {
		  fprintf(stderr, "read_ppm()  unable to allocate %d x %d unsigned ints for the picture\n", width, height);
		  return NULL; // fail but return
	 }

	 // allocate buffer to read the rest of the file into
	 int bufsize =  3 * width * height * sizeof(unsigned char);
	 if ((*maxval) > 255) {
		  bufsize *= 2;
	 }

	 unsigned char *buf = (unsigned char *)malloc(bufsize);
	 if (!buf) {
		  fprintf(stderr, "read_ppm()  unable to allocate %d bytes of read buffer\n", bufsize);
		  return NULL; // fail but return
	 }

	 // TODO really read
	 char duh[80];
	 char *line = chars;

	 // find the start of the pixel data.	no doubt stupid
	 sprintf(duh, "%d\0", *xsize);
	 line = strstr(line, duh);
	 //fprintf(stderr, "%s found at offset %d\n", duh, line-chars);
	 line += strlen(duh) + 1;

	 sprintf(duh, "%d\0", *ysize);
	 line = strstr(line, duh);
	 //fprintf(stderr, "%s found at offset %d\n", duh, line-chars);
	 line += strlen(duh) + 1;

	 sprintf(duh, "%d\0", *maxval);
	 line = strstr(line, duh);

	 fprintf(stderr, "%s found at offset %d\n", duh, line - chars);
	 line += strlen(duh) + 1;

	 long offset = line - chars;
	 //lseek(fd, offset, SEEK_SET); // move to the correct offset
	 fseek(fp, offset, SEEK_SET); // move to the correct offset
	 //long numread = read(fd, buf, bufsize);
	 long numread = fread(buf, sizeof(char), bufsize, fp);
	 fprintf(stderr, "Texture %s	read %ld of %ld bytes\n", filename, numread, bufsize);

	 fclose(fp);

	 int pixels = (*xsize) * (*ysize);
	 int i;
	 for (i=0; i<pixels; i++) {
		  pic[i] = (int) buf[3*i];  // red channel
	 }

	 return pic; // success

}

void write_ppm( char *filename, int xsize, int ysize, int maxval, int *pic) {

	 FILE *fp;

	 fp = fopen(filename, "w");
	 if (!fp) {
		  fprintf(stderr, "FAILED TO OPEN FILE '%s' for writing\n");
		  exit(-1);
	 }

	 fprintf(fp, "P6\n");
	 fprintf(fp,"%d %d\n%d\n", xsize, ysize, maxval);

	 int numpix = xsize * ysize;
	 int i;
	 for (i=0; i<numpix; i++) {
		  unsigned char uc = (unsigned char) pic[i];
		  fprintf(fp, "%c%c%c", uc, uc, uc);
	 }

	 fclose(fp);

}

int main(int argc, char **argv) {

	 char *filename;
	 filename = strdup(DEFAULT_FILENAME);

	 int threshold;
	 threshold = DEFAULT_THRESHOLD;

	 if (argc > 1) {
		  if (argc == 3) {
				filename = strdup(argv[1]);
				threshold = atoi(argv[2]);
		  }
		  if (argc == 2) {
				threshold = atoi(argv[1]);
		  }
	 }

	 int xsize, ysize, maxval;
	 unsigned int *pic = read_ppm(filename, &ysize, &xsize, &maxval);

	 int size = xsize * ysize;

	 dim3 BLOCK(32, 32);

	 dim3 GRID((int)ceil((float)ysize / 32), (int)ceil((float)xsize / 32));

	 unsigned int *h_ingoing;

	 int *h_outgoing;

	 h_ingoing = pic;

	 h_outgoing = (int *)calloc(size, sizeof *h_outgoing);

	 unsigned int *d_ingoing;

	 int *d_outgoing;

	 cudaMalloc(&d_ingoing, size * sizeof *d_ingoing);

	 cudaMalloc(&d_outgoing, size * sizeof *d_outgoing);

	 cudaMemcpy(d_ingoing, h_ingoing, size * sizeof *h_ingoing, cudaMemcpyHostToDevice);

	 cudaMemcpy(d_outgoing, h_outgoing, size * sizeof *h_outgoing, cudaMemcpyHostToDevice);

	 float time;

	 cudaEvent_t begin, end;

	 cudaEventCreate(&begin);

	 cudaEventCreate(&end);
	 cudaEventRecord(begin, 0);

	 sobel<<<GRID, BLOCK>>>(d_ingoing, d_outgoing, xsize, ysize, threshold);

	 cudaEventRecord(end, 0);


	 cudaEventSynchronize(end);


	 cudaEventElapsedTime(&time, begin, end);

	 cudaMemcpy(h_outgoing, d_outgoing, size * sizeof *h_outgoing, cudaMemcpyDeviceToHost);

	 printf("%f\n", time);

	 write_ppm("result.ppm", ysize, xsize, 255, h_outgoing);
	 
}

