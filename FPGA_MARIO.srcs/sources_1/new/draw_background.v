`timescale 1 ns / 1 ps

module DrawBackground (
	input wire [9:0] hcount_in,
	input wire hsync_in,
	input wire [9:0] vcount_in,
	input wire vsync_in,
  	input wire blnk_in,  
  	input wire [9:0] xoffset,
  	input wire clk,
  	input wire rst,
 
  	output reg [9:0] hcount_out,
  	output reg hsync_out,
  	output reg [9:0] vcount_out,
  	output reg vsync_out,
  	output reg [23:0] rgb_out,
  	output reg blnk_out
 );
    //Colors
	localparam BLACK	= 24'h00_00_00;
	localparam WHITE	= 24'hff_ff_ff;
	//Cords
	localparam OFFSET	= 100;
	localparam YRES		= 480;
	
	reg [7:0] r, g, b;
	reg [23:0] rgb_cl;
	reg [9:0]  hcount_cl, vcount_cl;
	reg hsync_cl, vsync_cl, blnk_cl;
	
    wire [9:0] hcount_cl_out, vcount_cl_out;
    wire [23:0] rgb_cl_out;
  
    Clouds Clouds_u(
        .clk(clk),
        .rst(rst),
        .xoffset(xoffset),
        .hcount_in(hcount_cl),
        .hsync_in(hsync_cl),
        .vcount_in(vcount_cl),
        .vsync_in(vsync_cl),
        .rgb_in(rgb_cl),
        .blnk_in(blnk_cl),

        .hcount_out(hcount_cl_out),
        .hsync_out(hsync_cl_out),
        .vcount_out(vcount_cl_out),
        .vsync_out(vsync_cl_out),
        .rgb_out(rgb_cl_out),
        .blnk_out(blnk_cl_out)
  	);

  	always @(posedge clk or posedge rst) begin   
        if(rst) begin
            hcount_cl   <= #1 0;
            hsync_cl    <= #1 0;
            vcount_cl   <= #1 0;
            vsync_cl    <= #1 0;
            rgb_cl      <= #1 0;
            blnk_cl     <= #1 0;
            hcount_out  <= #1 0;
            hsync_out   <= #1 0;
            vcount_out  <= #1 0;
            vsync_out   <= #1 0;
            rgb_out     <= #1 0;
            blnk_out    <= #1 0;
        end
        else begin
            hcount_cl   <= #1 hcount_in;
            hsync_cl    <= #1 hsync_in;
            vcount_cl   <= #1 vcount_in;
            vsync_cl    <= #1 vsync_in; 
            rgb_cl      <= #1 {r,g,b};  
            blnk_cl     <= #1 blnk_in;
            hcount_out  <= #1 hcount_cl_out;
            hsync_out   <= #1 hsync_cl_out;
            vcount_out  <= #1 vcount_cl_out;
            vsync_out   <= #1 vsync_cl_out;
            rgb_out     <= #1 rgb_cl_out;  
            blnk_out    <= #1 blnk_cl_out;
        end       
    end

    //Display gradiented sky
	always @* begin  
        if((YRES - vcount_in - 1) < OFFSET) {r,g,b} = WHITE; // any color, will be overwritten 
        else begin
            {b} = 8'hff;
            {r} = (vcount_in >> 1); 
            {g} = (vcount_in >> 1); 
        end
	end
  
endmodule
