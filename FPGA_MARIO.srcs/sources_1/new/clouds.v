`timescale 1 ns / 1 ps

module Clouds (
	input wire clk,
	input wire rst,
	input wire [9:0] xoffset,
	input wire [9:0] hcount_in,
  	input wire hsync_in,
	input wire [9:0] vcount_in,
	input wire vsync_in,
  	input wire [23:0] rgb_in,
  	input wire blnk_in,
 
  	output reg [9:0] hcount_out,
  	output reg hsync_out,
  	output reg [9:0] vcount_out,
  	output reg vsync_out,
  	output reg [23:0] rgb_out,
  	output reg blnk_out
	);

	localparam MAX_CLOUDS = 11;
	localparam YOFFSET  = 100;
	localparam XRES = 640;
	localparam YRES = 480;
	localparam CLOUD_COLOR = 24'h88_99_cc;
	localparam reg [10:0] CLOUD_MAP_X [0:10] = { 30, 90, 180, 220, 320, 450, 530, 590, 615, 0, 0};
	localparam reg [10:0] CLOUD_MAP_Y [0:10] = {100,100, 100, 100,  50,  70, 100, 100,  80, 0, 0};
	localparam reg [10:0] CLOUD_MAP_S [0:10] = { 30, 70,  25,  50, 100,  70,  25,  50,  40, 0, 0};
	
	reg [23:0] rgb_nxt;
	reg [3:0]  i;
	reg [10:0] xpos;
	
	always @(posedge clk or posedge rst) begin
        if(rst) begin
            hcount_out  <= #1 0;
            hsync_out   <= #1 0;
            vcount_out  <= #1 0;
            vsync_out   <= #1 0;
            rgb_out     <= #1 0;
            blnk_out    <= #1 0;
        end
        else begin
            hcount_out  <= #1 hcount_in;
            hsync_out   <= #1 hsync_in;
            vcount_out  <= #1 vcount_in;
            vsync_out   <= #1 vsync_in;
            rgb_out     <= #1 rgb_nxt;
            blnk_out    <= #1 blnk_in;
        end
	end
	
    always @* begin
        xpos = (hcount_in + xoffset) % (XRES - 1);
	end
	
	always @* begin
		if((YRES -1 - vcount_in) < YOFFSET ) rgb_nxt = CLOUD_COLOR;
		else begin
		//REQUIRES CHANGE BECAUSE OF TAKING TOO MUCH LUTS AND DSP, IT IS JUST CIRCLE EQUATION
                 if(((xpos - CLOUD_MAP_X[0])*(xpos - CLOUD_MAP_X[0]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[0])*(YRES -1 - vcount_in - CLOUD_MAP_Y[0]))< CLOUD_MAP_S[0]*CLOUD_MAP_S[0]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[1])*(xpos - CLOUD_MAP_X[1]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[1])*(YRES -1 - vcount_in - CLOUD_MAP_Y[1]))< CLOUD_MAP_S[1]*CLOUD_MAP_S[1]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[2])*(xpos - CLOUD_MAP_X[2]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[2])*(YRES -1 - vcount_in - CLOUD_MAP_Y[2]))< CLOUD_MAP_S[2]*CLOUD_MAP_S[2]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[3])*(xpos - CLOUD_MAP_X[3]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[3])*(YRES -1 - vcount_in - CLOUD_MAP_Y[3]))< CLOUD_MAP_S[3]*CLOUD_MAP_S[3]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[4])*(xpos - CLOUD_MAP_X[4]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[4])*(YRES -1 - vcount_in - CLOUD_MAP_Y[4]))< CLOUD_MAP_S[4]*CLOUD_MAP_S[4]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[5])*(xpos - CLOUD_MAP_X[5]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[5])*(YRES -1 - vcount_in - CLOUD_MAP_Y[5]))< CLOUD_MAP_S[5]*CLOUD_MAP_S[5]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[6])*(xpos - CLOUD_MAP_X[6]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[6])*(YRES -1 - vcount_in - CLOUD_MAP_Y[6]))< CLOUD_MAP_S[6]*CLOUD_MAP_S[6]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[7])*(xpos - CLOUD_MAP_X[7]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[7])*(YRES -1 - vcount_in - CLOUD_MAP_Y[7]))< CLOUD_MAP_S[7]*CLOUD_MAP_S[7]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[8])*(xpos - CLOUD_MAP_X[8]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[8])*(YRES -1 - vcount_in - CLOUD_MAP_Y[8]))< CLOUD_MAP_S[8]*CLOUD_MAP_S[8]) rgb_nxt = CLOUD_COLOR;
            else if(((xpos - CLOUD_MAP_X[9])*(xpos - CLOUD_MAP_X[9]) + (YRES -1 - vcount_in - CLOUD_MAP_Y[9])*(YRES -1 - vcount_in - CLOUD_MAP_Y[9]))< CLOUD_MAP_S[9]*CLOUD_MAP_S[9]) rgb_nxt = CLOUD_COLOR;
            else rgb_nxt = rgb_in;
        end
	end
	
endmodule
	
	
	