`timescale 1 ns / 1 ps

module VgaTiming (
	input  wire pclk,
	input  wire rst,
	  
	output reg [9:0] hcount,
	output reg hsync,
	output reg [9:0] vcount,
	output reg vsync,
	output reg blnk
	);

//	localparam H_TOTAL_TIME = 1056;
//    //localparam H_ADDR_TIME     = 800;
//    localparam H_BLNK_START = 800;
//    //localparam H_BLNK_TIME    = 160;
//    localparam H_SYNC_START    = 840;
//    localparam H_SYNC_TIME     = 128;
//    localparam H_SYNC_POL    = 1;    //0 - negative, 1 - positive
    
//    localparam V_TOTAL_TIME = 628;
//    //localparam V_ADDR_TIME     = 600;
//    localparam V_BLNK_START = 600;
//    //localparam V_BLNK_TIME    = 28;
//    localparam V_SYNC_START    = 601;
//    localparam V_SYNC_TIME     = 4;
//    localparam V_SYNC_POL    = 1;     //0 - negative, 1 - positive

  	localparam H_TOTAL_TIME = 800;
	//localparam H_ADDR_TIME 	= 640;
	localparam H_BLNK_START = 640;
	//localparam H_BLNK_TIME	= 160;
	localparam H_SYNC_START	= 656;
	localparam H_SYNC_TIME 	= 96;
	localparam H_SYNC_POL	= 0;	//0 - negative, 1 - positive
	
	localparam V_TOTAL_TIME = 525;
	//localparam V_ADDR_TIME 	= 480;
	localparam V_BLNK_START = 480;
	//localparam V_BLNK_TIME	= 45;
	localparam V_SYNC_START	= 490;
	localparam V_SYNC_TIME 	= 2;
	localparam V_SYNC_POL	= 0; 	//0 - negative, 1 - positive

	reg [10:0] vcount_nxt;
	reg vsync_nxt;
	reg [10:0] hcount_nxt;
	reg hsync_nxt;
	reg vblnk, hblnk;
	reg vblnk_nxt, hblnk_nxt;

    always @(posedge pclk or posedge rst) begin
		if (rst) begin
			hcount  <= #1 0;
            hsync   <= #1 0;
			vcount  <= #1 0;
	        vsync   <= #1 0;
	        hblnk   <= #1 0;
	        vblnk   <= #1 0;
        end
		else begin
		 	hcount  <= #1 hcount_nxt;
            hsync   <= #1 hsync_nxt;
			vcount  <= #1 vcount_nxt;
            vsync   <= #1 vsync_nxt;
            hblnk   <= #1 hblnk_nxt;
            vblnk   <= #1 vblnk_nxt;   
        end
    end
    
    always @* begin
        blnk = ~(hblnk | vblnk);
    end

	always @* begin
    	//horizontal
        if(hcount==H_BLNK_START - 1) begin
	        hcount_nxt = hcount+1;
	        if(H_SYNC_POL) hsync_nxt=0;
	        else hsync_nxt = 1;
	        hblnk_nxt=1; 
        end
        else if(hcount==H_SYNC_START - 1) begin
	        hcount_nxt = hcount+1;
	        if(H_SYNC_POL) hsync_nxt=1;
	        else hsync_nxt = 0;
            hblnk_nxt=1;    
        end
        else if (hcount==H_SYNC_START + H_SYNC_TIME - 1) begin
	        hcount_nxt = hcount+1;
	        if(H_SYNC_POL) hsync_nxt=0;
	        else hsync_nxt = 1;
            hblnk_nxt=1;  
        end
        else if (hcount==H_TOTAL_TIME - 1) begin
	        hcount_nxt = 0;
            if(H_SYNC_POL) hsync_nxt=0;
            else hsync_nxt = 1;
            hblnk_nxt=0;  
        end
        else begin
	        hcount_nxt = hcount+1;
            hsync_nxt = hsync;
            hblnk_nxt = hblnk;   
		end
		//vertical
        if(hcount==H_TOTAL_TIME - 1) begin
			if(vcount==V_BLNK_START - 1) begin
				vcount_nxt = vcount+1;
				if(V_SYNC_POL) vsync_nxt=0;
	        	else vsync_nxt = 1;
           		vblnk_nxt=1;             
            end
			else if (vcount==V_SYNC_START - 1) begin
				vcount_nxt = vcount+1;
				if(V_SYNC_POL) vsync_nxt=1;
	        	else vsync_nxt = 0;
           		vblnk_nxt = 1;    
            end
			else if (vcount==V_SYNC_START + V_SYNC_TIME - 1) begin
				vcount_nxt = vcount+1;
				if(V_SYNC_POL) vsync_nxt=0;
	        	else vsync_nxt = 1;
				vblnk_nxt = 1;
            end
			else if (vcount==V_TOTAL_TIME - 1) begin
				vcount_nxt = 0;
				if(V_SYNC_POL) vsync_nxt=0;
                else vsync_nxt = 1;
				vblnk_nxt = 0;
            end
			else begin
				vcount_nxt = vcount+1;
				vsync_nxt = vsync;
				vblnk_nxt = vblnk;
            end
        end
        else begin
	        vcount_nxt = vcount;
	        vsync_nxt = vsync;
	        vblnk_nxt = vblnk;   
        end
	end

endmodule
