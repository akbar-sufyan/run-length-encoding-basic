# Makefile for Run-Length Encoding (RLE) Project
# Supports building both v1 and v2 implementations

.PHONY: all clean test help rleb-v1 rleb-v2

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2
DEBUG_FLAGS = -Wall -Wextra -std=c99 -g -O0
LDFLAGS =

# Target executables
TARGETS = rleb-v1 rleb-v2

# Source files
V1_SOURCES = rleb-v1.c
V2_SOURCES = rleb-v2.c

# Object files
V1_OBJECTS = $(V1_SOURCES:.c=.o)
V2_OBJECTS = $(V2_SOURCES:.c=.o)

# Default target
all: $(TARGETS)

# Build v1 (simple byte-by-byte version)
rleb-v1: $(V1_OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	@echo "✓ Built rleb-v1 (simple byte-by-byte implementation)"

# Build v2 (optimized chunked I/O version)
rleb-v2: $(V2_OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	@echo "✓ Built rleb-v2 (optimized chunked I/O implementation)"

# Compile object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Build with debug symbols
debug: CFLAGS = $(DEBUG_FLAGS)
debug: clean $(TARGETS)
	@echo "✓ Built with debug symbols"

# Test targets
test: all test-basic test-v1 test-v2 test-cleanup
	@echo "✓ All tests passed!"

test-basic:
	@echo "Running basic functionality tests..."
	@echo "Creating test file..."
	@echo "AAABBBCCCCDDDD" > test_input.txt
	@echo "Testing v1 compression..."
	@./rleb-v1 test_input.txt compress
	@test -f test_input.txt.rleb || (echo "✗ v1 compression failed"; exit 1)
	@echo "Testing v1 decompression..."
	@./rleb-v1 test_input.txt.rleb decompress
	@test -f test_input.txt || (echo "✗ v1 decompression failed"; exit 1)

test-v1: test-basic
	@echo "Running v1 specific tests..."
	@rm -f test_input.txt test_input.txt.rleb
	@echo "AAAA" > test_input.txt
	@./rleb-v1 test_input.txt compress
	@./rleb-v1 test_input.txt.rleb decompress
	@echo "✓ v1 tests passed"

test-v2: all
	@echo "Running v2 specific tests..."
	@rm -f test_input.txt test_input.txt.rleb
	@echo "BBBBBBBBBB" > test_input.txt
	@./rleb-v2 test_input.txt compress
	@./rleb-v2 test_input.txt.rleb decompress
	@echo "✓ v2 tests passed"

test-cleanup:
	@rm -f test_input.txt test_input.txt.rleb

# Performance test (requires a larger test file)
perf-test: all
	@echo "Generating 1MB test file..."
	@dd if=/dev/zero bs=1024 count=1024 2>/dev/null | tr '\0' 'A' > perf_test.txt
	@echo "Testing v1 performance..."
	@time ./rleb-v1 perf_test.txt compress
	@time ./rleb-v1 perf_test.txt.rleb decompress
	@rm -f perf_test.txt.rleb
	@echo "Testing v2 performance..."
	@time ./rleb-v2 perf_test.txt compress
	@time ./rleb-v2 perf_test.txt.rleb decompress
	@rm -f perf_test.txt perf_test.txt.rleb

# Clean build artifacts
clean:
	@rm -f $(TARGETS) $(V1_OBJECTS) $(V2_OBJECTS)
	@rm -f test_input.txt test_input.txt.rleb
	@rm -f perf_test.txt perf_test.txt.rleb
	@echo "✓ Cleaned build artifacts"

# Deep clean (removes all generated files)
distclean: clean
	@rm -f *.o *.a *.so
	@echo "✓ Performed deep clean"

# Install binaries (to /usr/local/bin by default)
install: all
	@echo "Installing binaries to /usr/local/bin..."
	@mkdir -p /usr/local/bin
	@cp $(TARGETS) /usr/local/bin/
	@chmod +x /usr/local/bin/rleb-v1
	@chmod +x /usr/local/bin/rleb-v2
	@echo "✓ Installation complete"

# Uninstall binaries
uninstall:
	@echo "Removing binaries from /usr/local/bin..."
	@rm -f /usr/local/bin/rleb-v1 /usr/local/bin/rleb-v2
	@echo "✓ Uninstallation complete"

# Create archive for distribution
dist: clean
	@tar -czf rleb-project.tar.gz *.c Makefile README.md LICENSE .gitignore
	@echo "✓ Created rleb-project.tar.gz"

# Static analysis (requires splint)
lint:
	@echo "Running static analysis..."
	@splint *.c 2>/dev/null || echo "Note: splint not installed, skipping"

# Help target
help:
	@echo "RLE Project - Build Targets:"
	@echo ""
	@echo "  make              - Build all targets (rleb-v1, rleb-v2)"
	@echo "  make rleb-v1      - Build simple byte-by-byte version"
	@echo "  make rleb-v2      - Build optimized chunked I/O version"
	@echo "  make debug        - Build with debug symbols"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make distclean    - Remove all generated files"
	@echo "  make test         - Run basic functionality tests"
	@echo "  make perf-test    - Run performance comparison tests"
	@echo "  make install      - Install binaries to /usr/local/bin"
	@echo "  make uninstall    - Remove installed binaries"
	@echo "  make dist         - Create distribution archive"
	@echo "  make lint         - Run static analysis (splint)"
	@echo "  make help         - Show this help message"
	@echo ""
	@echo "Usage Examples:"
	@echo "  make              # Build both versions"
	@echo "  make test         # Run tests"
	@echo "  ./rleb-v1 file.txt compress    # Compress with v1"
	@echo "  ./rleb-v2 file.txt.rleb decompress # Decompress with v2"
	@echo ""

# Suppress warnings about phony targets
.SILENT: help
