`timescale 1ns / 1ps
module fifo_tb;
    localparam DATA_WIDTH = 8;
    localparam DEPTH      = 8;
    reg                     clk;
    reg                     rst_n;
    reg                     wr_en;
    reg  [DATA_WIDTH-1:0]   data_in;
    reg                     rd_en;
    wire [DATA_WIDTH-1:0]   data_out;
    wire                    full;
    wire                    empty;
    wire                    almost_full;
    wire                    almost_empty;

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .wr_en        (wr_en),
        .data_in      (data_in),
        .rd_en        (rd_en),
        .data_out     (data_out),
        .full         (full),
        .empty        (empty),
        .almost_full  (almost_full),
        .almost_empty (almost_empty)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    reg [DATA_WIDTH-1:0] ref_queue [0:31];
    integer ref_wr_idx = 0;
    integer ref_rd_idx = 0;

    task ref_push(input [DATA_WIDTH-1:0] val);
        begin
            ref_queue[ref_wr_idx] = val;
            ref_wr_idx = ref_wr_idx + 1;
        end
    endtask

    task check_read;
        reg [DATA_WIDTH-1:0] expected;
        begin
            expected = ref_queue[ref_rd_idx];
            ref_rd_idx = ref_rd_idx + 1;
            if (data_out === expected) begin
                pass_count = pass_count + 1;
                $display("PASS: expected=%h got=%h", expected, data_out);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: expected=%h got=%h", expected, data_out);
            end
        end
    endtask

    // Generic flag checker - pass a name string, expected value, actual value
    task check_flag(input [8*20-1:0] flag_name, input actual, input expected);
        begin
            if (actual === expected) begin
                pass_count = pass_count + 1;
                $display("PASS: %0s = %0d (expected %0d)", flag_name, actual, expected);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: %0s = %0d (expected %0d)", flag_name, actual, expected);
            end
        end
    endtask

    initial begin
        $display("========================================");
        $display(" FIFO Testbench Starting");
        $display("========================================");
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        data_in = 0;
        #20;
        rst_n = 1;
        #10;
        $display("Reset released. Beginning tests...");

        // =========================================================
        // TEST 1: Write 3 values, read them back (basic FIFO order)
        // =========================================================
        @(posedge clk); #1;
        wr_en = 1; data_in = 8'hA1; ref_push(8'hA1);
        @(posedge clk); #1;
        data_in = 8'hB2; ref_push(8'hB2);
        @(posedge clk); #1;
        data_in = 8'hC3; ref_push(8'hC3);
        @(posedge clk); #1;
        wr_en = 0;

        @(posedge clk); #1;
        rd_en = 1;
        @(posedge clk); #1; check_read();
        @(posedge clk); #1; check_read();
        @(posedge clk); #1; check_read();
        rd_en = 0;

        $display("---- Test 1 done. FIFO should be empty now. ----");
        @(posedge clk); #1;
        check_flag("empty_after_test1", empty, 1);

        // =========================================================
        // TEST 2: Fill FIFO completely (8 writes), check 'full'
        // =========================================================
        $display("---- Test 2: Filling FIFO completely ----");
        wr_en = 1;
        for (i = 0; i < DEPTH; i = i + 1) begin
            data_in = i + 8'h10;          // values 0x10, 0x11, ... 0x17
            ref_push(i + 8'h10);
            @(posedge clk); #1;
        end
        wr_en = 0;

        check_flag("full_after_filling", full, 1);

        // Try writing a 9th value while full -> should be ignored
        $display("---- Attempting write while FULL (should be ignored) ----");
        wr_en = 1; data_in = 8'hFF;   // this value should NOT be stored
        @(posedge clk); #1;
        wr_en = 0;
        check_flag("full_still_after_illegal_write", full, 1);

        // =========================================================
        // TEST 3: Drain FIFO completely (8 reads), check 'empty'
        // =========================================================
        $display("---- Test 3: Draining FIFO completely ----");
        rd_en = 1;
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge clk); #1;
            check_read();
        end
        rd_en = 0;

        check_flag("empty_after_draining", empty, 1);

        // Try reading while empty -> should be ignored, no crash
        $display("---- Attempting read while EMPTY (should be ignored) ----");
        rd_en = 1;
        @(posedge clk); #1;
        rd_en = 0;
        check_flag("empty_still_after_illegal_read", empty, 1);

        #20;
        $display("========================================");
        $display(" Testbench Finished");
        $display(" PASS = %0d   FAIL = %0d", pass_count, fail_count);
        $display("========================================");
        $finish;
    end
endmodule