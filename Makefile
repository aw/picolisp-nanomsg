# Makefile

PIL_MODULE_DIR ?= .modules
PIL_SYMLINK_DIR ?= .lib

## Edit below
BUILD_REPO = https://github.com/nanomsg/nanomsg.git
BUILD_DIR = $(PIL_MODULE_DIR)/nanomsg/HEAD
BUILD_REF = 1.1.5
TARGET = libnanomsg.so
## Edit above

# Unit testing
TEST_REPO = https://github.com/aw/picolisp-unit.git
TEST_DIR = $(PIL_MODULE_DIR)/picolisp-unit/HEAD

# Generic
COMPILE = make

.PHONY: all clean

all: $(BUILD_DIR) $(BUILD_DIR)/$(TARGET) symlink

$(BUILD_DIR):
		mkdir -p $(BUILD_DIR) && \
		git clone $(BUILD_REPO) $(BUILD_DIR)

$(TEST_DIR):
		mkdir -p $(TEST_DIR) && \
		git clone $(TEST_REPO) $(TEST_DIR)

$(BUILD_DIR)/$(TARGET):
		cd $(BUILD_DIR) && \
		git checkout $(BUILD_REF) && \
		./configure && \
		$(COMPILE) && \
		strip --strip-unneeded $(TARGET)

symlink:
		mkdir -p $(PIL_SYMLINK_DIR) && \
		cd $(PIL_SYMLINK_DIR) && \
		ln -sf ../$(BUILD_DIR)/$(TARGET) $(TARGET)

check: all $(TEST_DIR) run-tests

run-tests:
		PIL_NAMESPACES=false ./test.l

clean:
		cd $(BUILD_DIR) && \
		rm -f $(TARGET) && \
		cd - && \
		cd $(PIL_SYMLINK_DIR) && \
		rm -f $(TARGET)
