CPP=clang++

BASEFLAGS=-std=c++20 \
	-xc++ \
	-Werror \
	-Wall \
	-Wshadow \
	-Wunreachable-code \
	-pedantic \
	-I/usr/include/llvm \
	-Iliblunac/include

LIBSRC=$(wildcard liblunac/src/*.cpp)
LUNASRC=$(wildcard lunac/src/*.cpp)
TESTDIR = tests

OUTPUT_DEBUG   = output/debug
OUTPUT_RELEASE = output/release

MODE ?= debug

ifeq ($(MODE),release)
CPPFLAGS = $(BASEFLAGS) -O3 -flto
OUTPUT = $(OUTPUT_RELEASE)
else
CPPFLAGS = $(BASEFLAGS) -g -O0
OUTPUT = $(OUTPUT_DEBUG)
endif

TESTOUT = $(OUTPUT)/tests
TEST_CPP = $(wildcard $(TESTDIR)/*.cpp)
TEST_SH  = $(wildcard $(TESTDIR)/*.sh)
TEST_BIN = $(patsubst $(TESTDIR)/%.cpp,$(TESTOUT)/%,$(TEST_CPP))

# Object file mappings based on OUTPUT
LIBOBJ  = $(patsubst liblunac/src/%.cpp,$(OUTPUT)/liblunac_%.o,$(LIBSRC))
LUNAOBJ = $(patsubst lunac/src/%.cpp,$(OUTPUT)/lunac_%.o,$(LUNASRC))

DOCS_DIR=docs

BOOK_DIR = book
BOOK_OUT = $(DOCS_DIR)/book/index.html
BOOK_SRC = $(shell find $(BOOK_DIR)/src -name '*.md')

FORMAT_FILES := $(shell find . -name '*.cpp' -o -name '*.h')

# Default target
all: liblunac lunac

# Ensure output directory exists
$(OUTPUT):
	mkdir -p $(OUTPUT)

# Build library objects
$(OUTPUT)/liblunac_%.o: liblunac/src/%.cpp | $(OUTPUT)
	$(CPP) $(CPPFLAGS) -fPIC -c $< -o $@

# Build lunac objects
$(OUTPUT)/lunac_%.o: lunac/src/%.cpp | $(OUTPUT)
	$(CPP) $(CPPFLAGS) -c $< -o $@

# Build static and shared libraries
liblunac: $(LIBOBJ)
	ar rcs $(OUTPUT)/liblunac.a $(LIBOBJ)
	$(CPP) -shared -o $(OUTPUT)/liblunac.so $(LIBOBJ)

# Build lunac executable
lunac: $(LUNAOBJ) liblunac
	$(CPP) -o $(OUTPUT)/lunac $(LUNAOBJ) $(OUTPUT)/liblunac.a

clean:
	rm -rf output
	rm -rf docs/book

debug:
	$(MAKE) MODE=debug all

release:
	$(MAKE) MODE=release all

# ensure output dir exists
$(TESTOUT):
	mkdir -p $(TESTOUT)

# build each C++ test program, linking against liblunac
$(TESTOUT)/%: $(TESTDIR)/%.cpp liblunac | $(TESTOUT)
	$(CPP) $(CPPFLAGS) -o $@ $< -L$(OUTPUT) -llunac

# test target
test: debug $(TEST_BIN) liblunac
	@echo "Running C++ tests"
	@for t in $(TEST_BIN); do \
		echo "[$$t]"; $$t; \
	done
	@echo "Running shell tests"
	chmod u+x tests/*.sh
	@for s in $(TEST_SH); do \
		echo "[$$s]"; bash $$s; \
	done

# build book
book: $(BOOK_OUT)

$(BOOK_OUT): $(BOOK_SRC)
	~/.cargo/bin/mdbook build $(BOOK_DIR)

format:
	clang-format -i $(FORMAT_FILES)