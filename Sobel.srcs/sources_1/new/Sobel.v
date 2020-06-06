`timescale 1ns / 1ps

module Sobel(
    input clk,
    input en,
    input [31:0] stream_input,
    output [31:0] stream_output
    );

parameter WIDTH = 695; 
parameter EDGE_VALUE_THRESHOLD = 30;
reg signed [31:0] bfr [2*WIDTH+2:0];  // shift-register sliding buffer
reg signed [31:0] x_sum; // holds a +/- strength value for horizontal edges
reg signed [31:0] y_sum; // holds a +/- strength value for vertical edges
reg signed [32:0] abs_x; // |magnitude| of horizontal edge detection
reg signed [32:0] abs_y; // |magnitude| of vertical edge detection
reg signed [31:0] edge_val;  // 32-bit output pixel; sum of magnitudes

integer i;

initial 
    begin
    for (i = 0; i < (2*WIDTH+2); i=i+1)
        bfr[i] = 0; // initialize all buffer pixels to 0
    end

always @(posedge clk) begin
    if (en) begin
        // Move the stream_input pixel into the line buffer
        bfr[0] = $signed(stream_input);

        // Apply the sobel filter (x-dir)
        x_sum <= bfr[0]-bfr[2]+2*(bfr[WIDTH]-bfr[WIDTH+2])+bfr[2*WIDTH]-bfr[2*WIDTH+2];
	   // Aplly the sobel filter (y-dir)
	    y_sum <= bfr[0]+2*(bfr[1]-bfr[2*WIDTH+1])+bfr[2]-bfr[2*WIDTH]-bfr[2*WIDTH+2];
	
	    abs_x <= ($signed(x_sum) < 0) ? -$signed(x_sum) : x_sum; 
        abs_y <= ($signed(y_sum) < 0) ? -$signed(y_sum) : y_sum;

        // Add up the strength of horiz and vert edge values
        edge_val = abs_x + abs_y;

        // Shift each pixel value in the buffer 1 index to the left
        for(i = (2*WIDTH+2); i > 0; i=i-1)
            begin
            bfr[i] = bfr[i - 1];            
            end
        end 
    end

// If the sum of edge strengths exceed the edge-detection range, make it white
assign stream_output = (edge_val > EDGE_VALUE_THRESHOLD) ? 255 : 0; 

endmodule 
