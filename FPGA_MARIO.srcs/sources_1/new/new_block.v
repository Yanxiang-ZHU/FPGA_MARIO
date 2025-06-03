`timescale 1ns / 1ps

module new_block(
    input wire [5:0] block_in,
    input wire up_direction,
    input wire direction,
    input wire [9:0] relative_xpos,
    input wire [8:0] relative_ypos,
    output reg [5:0] block_out,
    output reg write_enable,
    output reg new_point
    );
    
    
    always @* begin
        if(block_in == GY) begin
            new_point = 1;
            block_out = B;
            write_enable = 1;
        end
        else if(((relative_xpos % 40) < 20) && (direction == 0)) begin
            if(block_in == D) begin
                if(up_direction) begin
                    new_point = 1;
                    block_out = DY;
                    write_enable = 1;
                end
                else begin
                    new_point = 0;
                    block_out = block_in;
                    write_enable = 0;
                end
            end
            else if(block_in == J) begin
                new_point = 0;
                if(up_direction) begin
                    block_out = B;
                    write_enable = 1;
                end
                else begin
                    block_out = block_in;
                    write_enable = 0;
                end
            end
            else begin
                new_point = 0;
                block_out = block_in;
                write_enable = 0;
            end  
        end
        else if(((relative_xpos % 40) >= 20) && (direction == 1)) begin
            if(block_in == D) begin
                if(up_direction) begin
                    new_point = 1;
                    block_out = DY;
                    write_enable = 1;
                end
                else begin
                    new_point = 0;
                    block_out = block_in;
                    write_enable = 0;
                end
            end
            else if(block_in == J) begin
                new_point = 0;
                if(up_direction) begin
                    block_out = B;
                    write_enable = 1;
                end
                else begin
                    block_out = block_in;
                    write_enable = 0;
                end
            end
            else begin
                new_point = 0;
                block_out = block_in;
                write_enable = 0;
            end  
        end
        else begin
            new_point = 0;
            block_out = block_in;
            write_enable = 0;
        end  
    end


            localparam	  A	   =	1	 ;
            localparam    B    =    0    ;
            localparam    C    =    2    ;
            localparam    D    =    3    ;
            localparam    E    =    4    ;
            localparam    F    =    5    ;
            localparam    G    =    6    ;
            localparam    H    =    7    ;
            localparam    I    =    8    ;
            localparam    J    =    9    ;
            localparam    K    =    10    ;
            localparam    L    =    11    ;
            localparam    M    =    12    ;
            localparam    N    =    13    ;
            localparam    O    =    14    ;
            localparam    P    =    15    ;
            localparam    Q    =    16    ;
            localparam    R    =    17    ;
            localparam    S    =    18    ;
            localparam    T    =    19    ;
            localparam    U    =    20    ;
            localparam    V    =    21    ;
            localparam    W    =    22    ;
            localparam    X    =    23    ;
            localparam    Y    =    24    ;
            localparam    Z    =    25    ;
            localparam    AY    =    26    ;
            localparam    IY    =    27    ;
            localparam    GY    =    28    ;
            localparam    KY    =    29    ;
            localparam    PY    =    30    ;
            localparam    TY    =    31    ;
            localparam    UY    =    32    ;
            localparam    WY    =    33    ;
            localparam    DY    =    34    ;
            localparam    BY    =    35    ;
            
            
            
            
    endmodule