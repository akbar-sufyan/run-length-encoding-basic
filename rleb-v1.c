/* rleb-v1: simple unoptimized version of Basic RLE
 *
 * BASIC: byte level run count encoding resulting in a pair of byte
 * FORMAT: [run_count][char]
 *
 * compression:
 *	- if already compressed file exists of the same name
 *	  it will overwrite it, re-compressing the data
 * decompression:
 * 	- if already decompressed file exists with same name
 * 	  it will overwrite it, re-decompressing the data
 * 	- if file extension does not match, it do not decompress
 * 	- if header/meta-data in file do not match, it do not decompress
 */

#include <stdio.h>	// printf, fopen
#include <string.h>	// strncpy, strcat
#include <stdlib.h>	// calloc, free

#define BASIC_EXTENSION ".rleb"
#define BASIC_HEADER "RLEB"

void compress(char* in_path)
{
	// open input file to compress
	FILE* in_file = fopen(in_path, "rb");
	if (in_file == NULL)
	{
		printf("input file not found\n");
		return;
	}

	// create a destination file
	// - create a file path with extension
	int out_path_size = strlen(in_path) + strlen(BASIC_EXTENSION) + 1;
	char* out_path = calloc(1, out_path_size);
	if (out_path == NULL)
	{
		printf("memory not allocated\n");
		fclose(in_file);
		return;
	}
	snprintf(out_path, out_path_size, "%s%s", in_path, BASIC_EXTENSION);

	// - create output file
	FILE* out_file = fopen(out_path, "wb");
	if (out_file == NULL)
	{
		printf("output file not created\n");
		free(out_path);
		fclose(in_file);
		return;
	}
	// - write meta-data/header to top of output file
	fputs(BASIC_HEADER, out_file);
	fputc('\n', out_file);

	// run-length-encoding
	int seen = fgetc(in_file);
	if (seen == EOF)
	{
		printf("empty input file\n");
		free(out_path);
		fclose(out_file);
		fclose(in_file);
		return;
	}
	int next;
	int count = 1;
	while ((next = fgetc(in_file)) != EOF)
	{
		if (next == seen && count < 255)	// range of byte
		{
			count++;
		}
		else
		{
			fputc(count, out_file);
			fputc(seen, out_file);
			seen = next;
			count = 1;
		}
	}
	fputc(count, out_file);
	fputc(seen, out_file);
	printf("%s encoded as %s\n", in_path, out_path);

	free(out_path);
	fclose(in_file);
	fclose(out_file);
}

void decompress(char* in_path)
{
	// confirm file extension
	int ext_index = strlen(in_path) - strlen(BASIC_EXTENSION);		// index at which extension start
	if (ext_index <= 0)
	{
		printf("incorrect path\n");	// file name too small, shorter than extension
		return;
	}
	if (strcmp(in_path + ext_index, BASIC_EXTENSION) != 0)
	{
		printf("extension not matched\n");
		return;
	}

	// open input file to decompress
	FILE* in_file = fopen(in_path, "rb");
	if (in_file == NULL)
	{
		printf("input file not found\n");
		return;
	}

	// confirm header/meta-data match
	int in_header_size = strlen(BASIC_HEADER) + 1;	// \0
	char* in_header = calloc(1, in_header_size);
	if (in_header == NULL)
	{
		printf("memory not allocated for header\n");
		return;
	}
	in_header = fgets(in_header, in_header_size, in_file);
	fgetc(in_file);	// \n
	if (in_header == NULL)
	{
		printf("header not received\n");
		free(in_header);
		fclose(in_file);
		return;
	}
	// in_header[in_header_size - 1] = '\0';	fgets already initialize it to \0
	if (strcmp(in_header, BASIC_HEADER) != 0)
	{
		printf("header/meta-data not matched: |%s| ~ |%s|\n", in_header, BASIC_HEADER);
		free(in_header);
		fclose(in_file);
		return;
	}

	// create a destination file
	// - create a file path without extension
	int out_path_size = ext_index + 1;
	char* out_path = calloc(1, out_path_size);
	if (out_path == NULL)
	{
		printf("memory not allocated for output path\n");
		free(in_header);
		fclose(in_file);
		return;
	}
	snprintf(out_path, out_path_size, "%.*s", ext_index, in_path);

	// - create output file
	FILE* out_file = fopen(out_path, "wb");
	if (out_file == NULL)
	{
		printf("output file not created\n");
		free(out_path);
		free(in_header);
		fclose(in_file);
		return;
	}

	// run-length-decoding
	while (1)
	{
		int count = fgetc(in_file);
		if (count == EOF)
		{
			break;
		}
		int seen = fgetc(in_file);
		if (seen == EOF)
		{
			break;
		}

		for (int i = 0 ; i < count ; i++)
		{
			fputc(seen, out_file);
		}
	}
	printf("%s decoded as %s\n", in_path, out_path);
	free(out_path);
	free(in_header);
	fclose(in_file);
	fclose(out_file);
}

int main(int argc, char* argv[])
{
	if (argc != 3)
	{
		printf("./rle file_path usage:[compress|decompress]\n");
		return -1;
	}

	char* in_path = argv[1];
	char* usage = argv[2];
	if (strcmp(usage, "compress") == 0)
	{
		compress(in_path);
	}
	else if (strcmp(usage, "decompress") == 0)
	{
		decompress(in_path);
	}
	else
	{
		printf("./rle file-in_path usage:[compress|decompress]\n");
		return -1;
	}
	return 0;
}
