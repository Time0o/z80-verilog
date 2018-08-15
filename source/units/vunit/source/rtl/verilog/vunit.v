module vunit();

	localparam VUNIT_HEADER = "| VUNIT";
	localparam MAX_INFO_LEN = 1000;

	task start;
		input [MAX_INFO_LEN-1:0] tc_name;
		$display("%s START %0s", VUNIT_HEADER, tc_name);
	endtask

	task finish;
		input [MAX_INFO_LEN-1:0] tc_name;
		begin
			$display("%s FINISH %0s", VUNIT_HEADER, tc_name);
			$finish;
		end
	endtask

	task assert;
		input condition;
		input [MAX_INFO_LEN-1:0] info;

		if (!condition) begin
			$display("%s ASSERT TRUE FAIL %0s", VUNIT_HEADER, info);
			$finish;
		end
	endtask

	task assert_eq;
		input expected;
		input actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected) begin
			$display("%s ASSERT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
			$finish;
		end
	endtask

	task assert_eq2;
		input [1:0] expected;
		input [1:0] actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected) begin
			$display("%s ASSERT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
			$finish;
		end
	endtask

	task assert_eq8;
		input [7:0] expected;
		input [7:0] actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected) begin
			$display("%s ASSERT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
			$finish;
		end
	endtask

	task assert_eq16;
		input [15:0] expected;
		input [15:0] actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected) begin
			$display("%s ASSERT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
			$finish;
		end
	endtask

	task expect;
		input condition;
		input [MAX_INFO_LEN-1:0] info;

		if (!condition)
			$display("%s EXPECT TRUE FAIL %0s", VUNIT_HEADER, info);
	endtask

	task expect_eq;
		input expected;
		input actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected)
			$display("%s EXPECT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
	endtask

	task expect_eq2;
		input [1:0] expected;
		input [1:0] actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected)
			$display("%s EXPECT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
	endtask

	task expect_eq8;
		input [7:0] expected;
		input [7:0] actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected)
			$display("%s EXPECT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
	endtask

	task expect_eq16;
		input [15:0] expected;
		input [15:0] actual;
		input [MAX_INFO_LEN-1:0] info;

		if (actual !== expected)
			$display("%s EXPECT EQ FAIL %0s (expected 0x%X but got 0x%X)",
                      VUNIT_HEADER, info, expected, actual);
	endtask

	task fail;
		input [MAX_INFO_LEN-1:0] info;
		begin
			$display("%s FAIL %0s", VUNIT_HEADER, info);
			$finish;
		end
	endtask

endmodule
