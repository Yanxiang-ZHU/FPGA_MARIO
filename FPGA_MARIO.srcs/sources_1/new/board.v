`timescale 1 ns / 1 ps

module Board (
    input wire [9:0] hcount_in,
    input wire hsync_in,
    input wire [9:0] vcount_in,
    input wire vsync_in,
    input wire pclk,
    input wire [23:0] rgb_in,
    input wire blnk_in,
    input wire clk,
    input wire rst,
    input wire [7:0] plane_xpos,
    input wire [5:0] plane_xpos_ofs,
    input wire [5:0] block,
    
    output reg [7:0] block_xpos,
    output reg [3:0] block_ypos,
    output reg [9:0] hcount_out,
    output reg hsync_out,
    output reg [9:0] vcount_out,
    output reg vsync_out,
    output reg [23:0] rgb_out,
    output reg blnk_out
    );
    //Definition of blocks, makes it easier to use
    localparam  A   =   1 ;
    localparam  B   =   0 ;
    localparam  C   =   2 ;
    localparam  D   =   3 ;
    localparam  E   =   4 ;
    localparam  F   =   5 ;
    localparam  G   =   6 ;
    localparam  H   =   7 ;
    localparam  I   =   8 ;
    localparam  J   =   9 ;
    localparam  K   =   10;
    localparam  L   =   11;
    localparam  M   =   12;
    localparam  N   =   13;
    localparam  O   =   14;
    localparam  P   =   15;
    localparam  Q   =   16;
    localparam  R   =   17;
    localparam  S   =   18;
    localparam  T   =   19;
    localparam  U   =   20;
    localparam  V   =   21;
    localparam  W   =   22;
    localparam  X   =   23;
    localparam  Y   =   24;
    localparam  Z   =   25;
    localparam  AY  =   26;
    localparam  IY  =   27;
    localparam  GY  =   28;
    localparam  KY  =   29;
    localparam  PY  =   30;
    localparam  TY  =   31;
    localparam  UY  =   32;
    localparam  WY  =   33;
    localparam  DY  =   34;
    
    reg [23:0] rgb_nxt;
    reg [7:0] block_xpos_nxt;
    reg [3:0] block_ypos_nxt;
    reg [11:0] ram_addr_nxt;
    
    always @* begin
        block_ypos_nxt  = ((479 - vcount_in)>>2)/10;
        block_xpos_nxt  = plane_xpos + ((hcount_in + plane_xpos_ofs)>>2)/10;
    end
    
    always @* begin
        case(block)//block colors
            A : rgb_nxt  = 24'h0_20_20 ;	 
            B : rgb_nxt  = rgb_in;
            C : rgb_nxt  = 24'h6A_3D_1E ;
            D : rgb_nxt  = 24'hBB_77_00 ;
            E : rgb_nxt  = 24'h00_00_00 ;
            F : rgb_nxt  = 24'h00_00_00 ;
            G : rgb_nxt  = 24'h10_50_10 ;
            H : rgb_nxt  = 24'h00_00_00 ;
            I : rgb_nxt  = 24'h00_00_00 ;
            J : rgb_nxt  = 24'h70_10_10 ;
            K : rgb_nxt  = 24'h00_00_00 ;
            L : rgb_nxt  = 24'h6A_3D_1E ;
            M : rgb_nxt  = 24'h6A_3D_1E ;
            N : rgb_nxt  = 24'h6A_3D_1E ;
            O : rgb_nxt  = 24'h50_30_20 ;
            P : rgb_nxt  = 24'h6A_3D_1E ;
            Q : rgb_nxt  = 24'h10_50_10 ;
            R : rgb_nxt  = rgb_in ;
            S : rgb_nxt  = 24'h6A_3D_1E ;
            T : rgb_nxt  = rgb_in ;
            U : rgb_nxt  = 24'h10_50_10 ;
            V : rgb_nxt  = 24'h10_50_10 ;
            W : rgb_nxt  = 24'h00_00_f0 ;
            X : rgb_nxt  = 24'h27_75_02 ;
            Y : rgb_nxt  = rgb_in ;
            Z : rgb_nxt  = 24'h30_30_f0 ;
            AY: rgb_nxt  = 24'h00_00_00 ;
            GY: rgb_nxt  = 24'hff_ff_00 ;
            KY: rgb_nxt  = 24'h00_00_00 ;
            PY: rgb_nxt  = 24'h00_00_00 ;
            TY: rgb_nxt  = 24'h00_00_00 ;
            WY: rgb_nxt  = 24'hb0_70_20 ;
            DY: rgb_nxt  = 24'h7A_4D_2E ;
            default: rgb_nxt = rgb_in;
        endcase
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            block_xpos  <= #1 0;
            block_ypos  <= #1 0;
        end
        else begin
            block_xpos  <= #1 block_xpos_nxt;
            block_ypos  <= #1 block_ypos_nxt;
        end    
    end
    
    always @(posedge pclk or posedge rst) begin
        if(rst) begin
            rgb_out     <= #1 0;
            hcount_out  <= #1 0;
            hsync_out   <= #1 0;
            vcount_out  <= #1 0;
            vsync_out   <= #1 0;
            blnk_out    <= #1 0;
        end
        else begin
            rgb_out     <= #1 rgb_nxt;
            hcount_out  <= #1 hcount_in;
            hsync_out   <= #1 hsync_in;     
            vcount_out  <= #1 vcount_in;
            vsync_out   <= #1 vsync_in;
            blnk_out    <= #1 blnk_in;
        end
    end
  
endmodule
