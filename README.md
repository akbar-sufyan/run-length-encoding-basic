# Run-Length Encoding (RLE) - Basic Implementation

A simple yet efficient run-length encoding utility with two versions: a basic unoptimized implementation and an optimized version using chunked I/O.

## Overview

Run-length encoding is a compression technique that encodes sequences of identical bytes into a count-character pair. This project provides two implementations to demonstrate the trade-offs between simplicity and performance.

### Features

- **Compression**: Converts any file into a compressed `.rleb` format
- **Decompression**: Restores compressed files to their original state
- **Metadata Validation**: Uses headers and file extensions to ensure integrity
- **Two Versions**:
  - `rleb-v1`: Simple, byte-by-byte implementation (easy to understand)
  - `rleb-v2`: Optimized chunked I/O implementation (better performance)

## Format Specification

**Compression Format**: `[run_count][char]`

- Each run of identical bytes is encoded as a pair: count followed by the character
- Count is a single byte (range: 1-255)
- Characters are encoded as-is
- Compressed files use `.rleb` extension
- Header: `RLEB` followed by newline

**Example**:
```
Input:  AAABBBCC
Output: [3][A][3][B][2][C]
```

## Versions

### Version 1 (rleb-v1)
- Reads and writes files byte-by-byte
- Simpler logic, easier to understand
- Suitable for small files or educational purposes
- Slower I/O performance

### Version 2 (rleb-v2)
- Uses 4KB chunked I/O for better performance
- Buffers input and output operations
- Handles incomplete pairs at chunk boundaries
- Recommended for production use and larger files

## Building

### Requirements
- GCC or Clang compiler
- GNU Make
- Standard C library (libc)

### Compilation

```bash
# Build all versions
make

# Build specific version
make rleb-v1
make rleb-v2

# Build and run tests
make test

# Clean build artifacts
make clean
```

## Usage

### Compress a file
```bash
./rleb-v1 input.txt compress
./rleb-v2 input.txt compress
```

Output: `input.txt.rleb`

### Decompress a file
```bash
./rleb-v1 input.txt.rleb decompress
./rleb-v2 input.txt.rleb decompress
```

Output: `input.txt`

### Command Format
```
./rle <file_path> <usage>
  <file_path> - path to the file to compress or decompress
  <usage>     - either "compress" or "decompress"
```

## Implementation Details

### Compression Algorithm
1. Read input file
2. Write header (`RLEB\n`)
3. Count consecutive identical bytes
4. Write count-character pairs
5. Handle count overflow (max 255 bytes per run)

### Decompression Algorithm
1. Validate file extension (`.rleb`)
2. Read and verify header
3. Read count-character pairs
4. Expand pairs into original data
5. Write decompressed output

### Key Differences (v1 vs v2)

| Feature | v1 | v2 |
|---------|----|----|
| I/O Method | Byte-by-byte | Chunked (4KB) |
| Buffer Size | 1 byte | 4096 bytes |
| Chunk Processing | N/A | Yes |
| Boundary Handling | Simple | Complex |
| Performance | Slower | Faster |
| Code Complexity | Simple | Moderate |

## Error Handling

Both versions handle the following error cases:
- File not found
- Memory allocation failures
- Invalid file extensions
- Header mismatches
- Empty input files
- Incomplete file pairs (v2 only)

## Performance Considerations

- **Compression ratio**: Varies greatly depending on input data
  - Highly repetitive data: can achieve 90%+ compression
  - Random data: may expand file size slightly
- **Speed**: v2 is significantly faster on large files due to chunked I/O
- **Memory**: Both versions use minimal memory (v2 uses 8KB for buffers)

## File Overwriting

Both versions will overwrite existing files:
- During compression: overwrites `.rleb` file of the same name
- During decompression: overwrites original file of the same name

Use with caution on important files.

## Limitations

- Maximum run length: 255 bytes
- Designed for byte-level compression
- Not suitable for already-compressed files (ZIP, JPEG, etc.)
- No error correction or checksums

## Examples

### Example 1: Text File
```bash
$ echo "AAABBBCCCC" > test.txt
$ ./rleb-v2 test.txt compress
test.txt encoded as test.txt.rleb

$ ./rleb-v2 test.txt.rleb decompress
test.txt.rleb decoded as test.txt

$ cat test.txt
AAABBBCCCC
```

### Example 2: Performance Comparison
For a 1MB file with repetitive data, v2 typically runs 3-5x faster than v1.

## License

MIT License - See LICENSE file for details

## Contributing

This is an educational project demonstrating compression techniques and I/O optimization. Feel free to use it as a learning resource.

## Future Improvements

- Add support for runs longer than 255 bytes
- Implement escape sequences for better incompressible data handling
- Add progress indicators for large files
- Add checksum validation for decompressed data
- Support for standard input/output pipes
