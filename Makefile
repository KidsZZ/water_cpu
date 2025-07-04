# Makefile for MIPS Single-Cycle CPU Project
# Author: Generated for water_cpu project
# Date: $(shell date)

# ============================================================================
# Configuration Variables
# ============================================================================

# Project settings
PROJECT_NAME = water_cpu
TOP_MODULE = sccomp_tb
MAIN_MODULE = sccomp

# Tool settings
SIMULATOR = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Directories
SRC_DIR = .
SRC_SUBDIR = src
TEST_DIR = .
BUILD_DIR = build
RESULTS_DIR = results

# File extensions and patterns
VERILOG_SRCS = $(filter-out $(TOP_MODULE).v, $(wildcard *.v) $(wildcard $(SRC_SUBDIR)/*.v))
TESTBENCH = $(TOP_MODULE).v
MEMORY_FILE = Test_37_Instr2.dat

# Output files
EXECUTABLE = $(BUILD_DIR)/$(PROJECT_NAME)
VCD_FILE = $(BUILD_DIR)/$(PROJECT_NAME).vcd
RESULTS_FILE = $(RESULTS_DIR)/results.txt

# Compiler flags
IVERILOG_FLAGS = -g2012 -Wall -I./$(SRC_SUBDIR)

# 支持通过 make run STOP_INSTR=10 方式传递 stop_instr 宏
STOP_INSTR ?=
VVP_FLAGS = 

# Color codes for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
PURPLE = \033[0;35m
CYAN = \033[0;36m
NC = \033[0m # No Color

# ============================================================================
# Default Target
# ============================================================================

.PHONY: all
all: compile

# ============================================================================
# Help Target
# ============================================================================

.PHONY: help
help:
	@echo "$(CYAN)================================================$(NC)"
	@echo "$(CYAN)  $(PROJECT_NAME) Makefile Help$(NC)"
	@echo "$(CYAN)================================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Main Targets:$(NC)"
	@echo "  $(GREEN)compile$(NC)     - Compile the Verilog design"
	@echo "  $(GREEN)simulate$(NC)    - Run simulation"
	@echo "  $(GREEN)run$(NC)         - Compile and run simulation"
	@echo "  $(GREEN)wave$(NC)        - Open waveform viewer (GTKWave)"
	@echo ""
	@echo "$(YELLOW)Testing Targets:$(NC)"
	@echo "  $(GREEN)test$(NC)        - Run all tests"
	@echo "  $(GREEN)test-quick$(NC)  - Run quick test"
	@echo ""
	@echo "$(YELLOW)Utility Targets:$(NC)"
	@echo "  $(GREEN)clean$(NC)       - Clean build files"
	@echo "  $(GREEN)clean-all$(NC)   - Clean all generated files"
	@echo "  $(GREEN)info$(NC)        - Show project information"
	@echo "  $(GREEN)check$(NC)       - Check for required tools"
	@echo ""
	@echo "$(YELLOW)Debug Targets:$(NC)"
	@echo "  $(GREEN)debug$(NC)       - Run simulation with debug output"
	@echo "  $(GREEN)lint$(NC)        - Run syntax check"
	@echo ""
	@echo "$(YELLOW)Variables:$(NC)"
	@echo "  TOP_MODULE=$(TOP_MODULE)"
	@echo "  SIMULATOR=$(SIMULATOR)"
	@echo "  BUILD_DIR=$(BUILD_DIR)"

# ============================================================================
# Setup Targets
# ============================================================================

.PHONY: init
init: $(BUILD_DIR) $(RESULTS_DIR)
	@echo "$(GREEN)Project initialized successfully!$(NC)"

$(BUILD_DIR):
	@echo "$(BLUE)Creating build directory...$(NC)"
	@mkdir -p $(BUILD_DIR)

$(RESULTS_DIR):
	@echo "$(BLUE)Creating results directory...$(NC)"
	@mkdir -p $(RESULTS_DIR)

# ============================================================================
# Compilation Targets
# ============================================================================

.PHONY: compile
compile: $(EXECUTABLE)

$(EXECUTABLE): $(VERILOG_SRCS) $(TESTBENCH) | $(BUILD_DIR)
	   @echo "$(BLUE)Compiling Verilog sources...$(NC)"
	   @echo "$(CYAN)Sources: $(VERILOG_SRCS)$(NC)"
	   @echo "$(CYAN)Testbench: $(TESTBENCH)$(NC)"
	   if [ -z "$(STOP_INSTR)" ]; then \
		 $(SIMULATOR) $(IVERILOG_FLAGS) -o $@ $(VERILOG_SRCS) $(TESTBENCH); \
	   else \
		 $(SIMULATOR) $(IVERILOG_FLAGS) -DSTOP_INSTR=$(STOP_INSTR) -o $@ $(VERILOG_SRCS) $(TESTBENCH); \
	   fi
	   @echo "$(GREEN)Compilation successful!$(NC)"

# ============================================================================
# Simulation Targets
# ============================================================================

.PHONY: simulate sim
simulate sim: $(EXECUTABLE) | $(RESULTS_DIR)
	@echo "$(BLUE)Running simulation...$(NC)"
	@cd $(SRC_DIR) && $(VVP) $(VVP_FLAGS) $(EXECUTABLE)
	@if [ -f results.txt ]; then \
		mv results.txt $(RESULTS_FILE); \
		echo "$(GREEN)Simulation completed! Results saved to $(RESULTS_FILE)$(NC)"; \
	else \
		echo "$(YELLOW)Simulation completed! No results file generated.$(NC)"; \
	fi

.PHONY: run
run: clean compile simulate

.PHONY: debug
debug: $(EXECUTABLE) | $(RESULTS_DIR)
	@echo "$(BLUE)Running simulation with debug output...$(NC)"
	@cd $(SRC_DIR) && $(VVP) $(VVP_FLAGS) -v $(EXECUTABLE)
	@if [ -f results.txt ]; then mv results.txt $(RESULTS_FILE); fi

# ============================================================================
# Waveform Targets
# ============================================================================

.PHONY: wave waves
wave waves: $(VCD_FILE)
	@echo "$(BLUE)Opening waveform viewer...$(NC)"
	@$(GTKWAVE) $(VCD_FILE) &

$(VCD_FILE): simulate
	@if [ -f dump.vcd ]; then \
		mv dump.vcd $(VCD_FILE); \
		echo "$(GREEN)Waveform file created: $(VCD_FILE)$(NC)"; \
	else \
		echo "$(YELLOW)No waveform file generated during simulation$(NC)"; \
	fi

# ============================================================================
# Testing Targets
# ============================================================================

.PHONY: test
test: compile
	@echo "$(BLUE)Running comprehensive tests...$(NC)"
	@$(MAKE) simulate
	@echo "$(GREEN)All tests completed!$(NC)"

.PHONY: test-quick
test-quick: compile
	@echo "$(BLUE)Running quick test...$(NC)"
	@$(MAKE) simulate
	@echo "$(GREEN)Quick test completed!$(NC)"

# ============================================================================
# Utility Targets
# ============================================================================

.PHONY: lint
lint:
	@echo "$(BLUE)Running syntax check...$(NC)"
	@$(SIMULATOR) $(IVERILOG_FLAGS) -t null $(VERILOG_SRCS) $(TESTBENCH) > /dev/null
	@echo "$(GREEN)Syntax check passed!$(NC)"

.PHONY: check
check:
	@echo "$(BLUE)Checking for required tools...$(NC)"
	@which $(SIMULATOR) > /dev/null || (echo "$(RED)Error: $(SIMULATOR) not found!$(NC)" && exit 1)
	@which $(VVP) > /dev/null || (echo "$(RED)Error: $(VVP) not found!$(NC)" && exit 1)
	@which $(GTKWAVE) > /dev/null || echo "$(YELLOW)Warning: $(GTKWAVE) not found (waveform viewing unavailable)$(NC)"
	@echo "$(GREEN)Tool check completed!$(NC)"

.PHONY: info
info:
	@echo "$(CYAN)================================================$(NC)"
	@echo "$(CYAN)  Project Information$(NC)"
	@echo "$(CYAN)================================================$(NC)"
	@echo "Project Name:    $(PROJECT_NAME)"
	@echo "Top Module:      $(TOP_MODULE)"
	@echo "Main Module:     $(MAIN_MODULE)"
	@echo "Source Files:    $(words $(VERILOG_SRCS)) files"
	@echo "Testbench:       $(TESTBENCH)"
	@echo "Memory File:     $(MEMORY_FILE)"
	@echo "Simulator:       $(SIMULATOR)"
	@echo "Build Directory: $(BUILD_DIR)"
	@echo "Results Dir:     $(RESULTS_DIR)"
	@echo ""
	@echo "$(YELLOW)Source Files:$(NC)"
	@for file in $(VERILOG_SRCS); do echo "  $$file"; done

# ============================================================================
# Clean Targets
# ============================================================================

.PHONY: clean
clean:
	@echo "$(BLUE)Cleaning build files...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -f *.vcd dump.vcd
	@rm -f results.txt
	@echo "$(GREEN)Build files cleaned!$(NC)"

.PHONY: clean-all
clean-all: clean
	@echo "$(BLUE)Cleaning all generated files...$(NC)"
	@rm -rf $(RESULTS_DIR)
	@rm -f *.out
	@echo "$(GREEN)All files cleaned!$(NC)"

.PHONY: distclean
distclean: clean-all
	@echo "$(GREEN)Project reset to clean state!$(NC)"

# ============================================================================
# Advanced Targets (for future extension)
# ============================================================================

.PHONY: synthesis
synthesis:
	@echo "$(YELLOW)Synthesis target not implemented yet$(NC)"
	@echo "$(BLUE)This target can be extended for FPGA synthesis$(NC)"

.PHONY: formal
formal:
	@echo "$(YELLOW)Formal verification target not implemented yet$(NC)"
	@echo "$(BLUE)This target can be extended for formal verification$(NC)"

.PHONY: coverage
coverage:
	@echo "$(YELLOW)Coverage analysis target not implemented yet$(NC)"
	@echo "$(BLUE)This target can be extended for coverage analysis$(NC)"

# ============================================================================
# File Dependencies
# ============================================================================

# Add specific module dependencies here as the project grows
# Example:
# sccomp.v: SCPU.v PC.v IM.v DM.v
# SCPU.v: RF.v ALU.v CTRL.v

# ============================================================================
# Special Targets
# ============================================================================

.PHONY: watch
watch:
	@echo "$(BLUE)Watching for file changes...$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to stop$(NC)"
	@while inotifywait -e modify $(VERILOG_SRCS) $(TESTBENCH) 2>/dev/null; do \
		echo "$(CYAN)File changed, recompiling...$(NC)"; \
		$(MAKE) compile; \
	done

# Print variables for debugging
.PHONY: vars
vars:
	@echo "VERILOG_SRCS = $(VERILOG_SRCS)"
	@echo "TESTBENCH = $(TESTBENCH)"
	@echo "EXECUTABLE = $(EXECUTABLE)"
	@echo "BUILD_DIR = $(BUILD_DIR)"
	@echo "RESULTS_DIR = $(RESULTS_DIR)"

# ============================================================================
# Include custom rules (for future extension)
# ============================================================================

-include local.mk
