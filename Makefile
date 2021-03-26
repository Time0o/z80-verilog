RTL_DIR := source/rtl
INC_DIR := source/include
TB_DIR  := source/testbench
RUN_DIR := run

VERILOG := iverilog

RTL_EXCLUDE := top_z80.v pads.v
RTL_EXCLUDE := $(patsubst %.v,$(RTL_DIR)/%.v,$(RTL_EXCLUDE))

RTL := $(wildcard $(RTL_DIR)/*.v)
RTL := $(filter-out $(RTL_EXCLUDE),$(RTL))

TB := $(TB_DIR)/tb_top_z80.v

Z80_TEST := $(RUN_DIR)/z80_test

test_processor: $(Z80_TEST)

$(Z80_TEST): $(TB) $(RTL)
	$(VERILOG) -o $@ $(TB) $(RTL) -I $(INC_DIR) -DIVERILOG

define compile_test_program
  if ! [ -f "$(PROG)" ]; then \
    >&2 echo "PROG must point to C source file" ; \
    exit 1 ; \
  fi ; \
  cp $(PROG) testprogs/source ; \
  make -C testprogs ; \
  cp testprogs/z80/$(patsubst %.c,%,$(PROG))/prog.progmem_int $(RUN_DIR)/progmem.txt
endef

test_program:
	@$(call compile_test_program)

.PHONY: clean

clean:
	rm -f $(Z80_TEST) $(RUN_DIR)/progmem.txt
