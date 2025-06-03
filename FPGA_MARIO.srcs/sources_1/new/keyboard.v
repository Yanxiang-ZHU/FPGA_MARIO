
module Keyboard(
	input wire CLK,		//board clock
   	input wire PS2_CLK,	//keyboard clock and data signals
   	input wire PS2_DATA,
   	input wire rst,

	output reg L_ALT,
	output reg R_ALT,
	output reg L_CTRL,
	output reg R_CTRL,
	output reg SPACE,
	output reg L_SHIFT,
	output reg R_SHIFT,
	output reg ESC,
	output reg D_ARROW,
	output reg L_ARROW,
	output reg R_ARROW
   	);
    
    localparam reg [7:0] ALT_CODE      = 8'h11;
    localparam reg [7:0] CTRL_CODE     = 8'h14;
	localparam reg [7:0] SPACE_CODE    = 8'h29;
    localparam reg [7:0] L_SHIFT_CODE  = 8'h12;
    localparam reg [7:0] R_SHIFT_CODE  = 8'h59;
    localparam reg [7:0] ESC_CODE      = 8'h76;
	localparam reg [7:0] D_ARROW_CODE  = 8'h72;
	localparam reg [7:0] L_ARROW_CODE  = 8'h6B;
	localparam reg [7:0] R_ARROW_CODE  = 8'h74;
    localparam reg [7:0] BREAK_CODE    = 8'hF0;
	localparam reg [7:0] EXTENDED_CODE = 8'hE0;
	localparam reg [7:0] L_GUI         = 8'h1F;
	localparam reg [7:0] R_GUI         = 8'h27;
	localparam reg [7:0] APPS          = 8'h2F;
	
    reg EXTENDED_nxt;
    reg BREAK_nxt;
	reg L_ALT_nxt;
    reg R_ALT_nxt;
    reg L_CTRL_nxt;
    reg R_CTRL_nxt;
    reg SPACE_nxt;
    reg L_SHIFT_nxt;
    reg R_SHIFT_nxt;
    reg ESC_nxt;
    reg D_ARROW_nxt;
    reg L_ARROW_nxt;
    reg R_ARROW_nxt;

	reg read;				   //this is 1 if still waits to receive more bits 
    reg [11:0] count_reading;  //this is used to detect how much time passed since it received the previous codeword
	reg PREVIOUS_STATE;        //used to check the previous state of the keyboard clock signal to know if it changed
	reg [10:0] scan_code;      //this stores 11 received bits
	reg scan_err;              //this tells about error
	reg [7:0] CODEWORD;        //this stores only the DATA codeword
	reg TRIG_ARR;			   //this is triggered when full 11 bits are received
	reg [3:0]BIT_COUNTER;      //tells how many bits were received until now (from 0 to 11)
	reg EXTENDED;
	reg BREAK;
	
	always @(posedge CLK or posedge rst) begin
        if(rst) begin
            count_reading <= #1 0;
        end
        else begin
            if (read)                       	       		//if it still waits to read full packet of 11 bits, then (read == 1)
                count_reading <= #1 count_reading + 1;      //and it counts up this variable
            else                 		     				//and later if check to see how big this value is.
                count_reading <= #1 0;          			//if it is too big, then it resets the received data
        end
	end

	always @(posedge CLK or posedge rst) begin		
        if(rst) begin
            PREVIOUS_STATE  <= #1 1;
            read            <= #1 0;
            scan_err        <= #1 0;
            scan_code       <= #1 11'b00000000000;
            BIT_COUNTER     <= #1 0;
            TRIG_ARR        <= #1 0;
        end
        else begin
            if (PS2_CLK != PREVIOUS_STATE) begin			//if the state of Clock pin changed from previous state
                if (!PS2_CLK) begin				//and if the keyboard clock is at falling edge
                    read <= #1 1;				//mark down that it is still reading for the next bit
                    scan_err <= #1 0;				//no errors
                    scan_code[10:0] <= #1 {PS2_DATA, scan_code[10:1]};	//add up the data received by shifting bits and adding one new bit
                    BIT_COUNTER <= #1 BIT_COUNTER + 1;			//
                end
            end
            else if (BIT_COUNTER == 11) begin				//if it already received 11 bits
                BIT_COUNTER <= #1 0;
                read <= #1 0;					//mark down that reading stopped
                TRIG_ARR <= #1 1;					//trigger out that the full pack of 11bits was received
                //calculate scan_err using parity bit
                if (!scan_code[10] || scan_code[0] || !(scan_code[1]^scan_code[2]^scan_code[3]^scan_code[4]
                    ^scan_code[5]^scan_code[6]^scan_code[7]^scan_code[8]
                    ^scan_code[9]))
                    scan_err <= #1 1;
                else 
                    scan_err <= #1 0;
            end	
            else  begin						//if it yet not received full pack of 11 bits
                TRIG_ARR <= #1 0;					//tell that the packet of 11bits was not received yet
                if (BIT_COUNTER < 11 && count_reading >= 4000) begin	//and if after a certain time no more bits were received, then
                    BIT_COUNTER <= #1 0;				//reset the number of bits received
                    read <= #1 0;				//and wait for the next packet
                end
            end
            PREVIOUS_STATE <= #1 PS2_CLK;					//mark down the previous state of the keyboard clock
        end
	end


	always @(posedge CLK or posedge rst) begin
        if(rst) begin
            CODEWORD <= #1 8'd0;
        end
        else begin
            if (TRIG_ARR) begin				//and if a full packet of 11 bits was received
                if (scan_err) begin			//BUT if the packet was NOT OK
                    CODEWORD <= #1 8'd0;		//then reset the codeword register
                end
                else begin
                    CODEWORD <= scan_code[8:1];	//else drop down the unnecessary  bits and transport the 7 DATA bits to CODEWORD reg
                end				//notice, that the codeword is also reversed! This is because the first bit to received
            end					//is supposed to be the last bit in the codeword?
            else CODEWORD <= #1 8'd0;				//not a full packet received, thus reset codeword
        end
	end
	
	always @(posedge CLK or posedge rst) begin
        if(rst) begin
            EXTENDED<= #1 0;
            BREAK   <= #1 0;
            L_ALT   <= #1 0;
            R_ALT   <= #1 0;
            L_CTRL  <= #1 0;
            R_CTRL  <= #1 0;
            L_SHIFT <= #1 0;
            R_SHIFT <= #1 0;
            SPACE   <= #1 0;
            ESC     <= #1 0;
            D_ARROW <= #1 0;
            L_ARROW <= #1 0;
            R_ARROW <= #1 0;
        end
        else begin
            EXTENDED<= #1 EXTENDED_nxt;
            BREAK   <= #1 BREAK_nxt;
            L_ALT   <= #1 L_ALT_nxt;
            R_ALT   <= #1 R_ALT_nxt;
            L_CTRL  <= #1 L_CTRL_nxt;
            R_CTRL  <= #1 R_CTRL_nxt;
            L_SHIFT <= #1 L_SHIFT_nxt;
            R_SHIFT <= #1 R_SHIFT_nxt;
            SPACE   <= #1 SPACE_nxt;
            ESC     <= #1 ESC_nxt;
            D_ARROW <= #1 D_ARROW_nxt;
            L_ARROW <= #1 L_ARROW_nxt;
            R_ARROW <= #1 R_ARROW_nxt;
        end        
	end
	
    always @* begin
        if(scan_err == 0) begin
            if(CODEWORD == EXTENDED_CODE) begin
                EXTENDED_nxt= 1;
                BREAK_nxt   = 0;
                L_ALT_nxt   = L_ALT;
                R_ALT_nxt   = R_ALT;
                L_CTRL_nxt  = L_CTRL;
                R_CTRL_nxt  = R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt   = SPACE;
                ESC_nxt     = ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end
            else if(CODEWORD == BREAK_CODE) begin
                EXTENDED_nxt= EXTENDED;
                BREAK_nxt 	= 1;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end
            else if(EXTENDED) begin
                if(CODEWORD == R_ARROW_CODE) begin
                    if(BREAK) begin
                        R_ARROW_nxt = 0;
                    end
                    else begin
                        R_ARROW_nxt = 1;
                    end
                    EXTENDED_nxt= 0;
                    BREAK_nxt 	= 0;
                    R_ALT_nxt 	= R_ALT;
                    R_CTRL_nxt 	= R_CTRL;
                end
                else if(CODEWORD == ALT_CODE) begin
                    if(BREAK) begin
                       R_ALT_nxt = 0;
                    end
                    else begin
                       R_ALT_nxt = 1;
                    end
                    BREAK_nxt 	= 0;
                    EXTENDED_nxt= 0;
                    R_CTRL_nxt 	= R_CTRL;
                    R_ARROW_nxt = R_ARROW;    
                end
                else if(CODEWORD == CTRL_CODE) begin
                    if(BREAK) begin
                        R_CTRL_nxt = 0;
                    end
                    else begin
                        R_CTRL_nxt = 1;
                    end
                    BREAK_nxt 	= 0;
                    EXTENDED_nxt= 0;
                    R_ALT_nxt 	= R_ALT;
                    R_ARROW_nxt = R_ARROW;    
                end
                else begin
                    EXTENDED_nxt= EXTENDED;
                    BREAK_nxt 	= BREAK;
                    R_ALT_nxt 	= R_ALT;
                    R_CTRL_nxt 	= R_CTRL;
                    R_ARROW_nxt = R_ARROW;
                end
                L_ALT_nxt	= L_ALT;
                L_CTRL_nxt 	= L_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
            end
            else if(CODEWORD == D_ARROW_CODE) begin
                if(BREAK) begin
                    D_ARROW_nxt = 0;
                end
                else begin
                    D_ARROW_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end
            else if(CODEWORD == L_ARROW_CODE) begin
                if(BREAK) begin
                    L_ARROW_nxt = 0;
                end
                else begin
                    L_ARROW_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                R_ARROW_nxt = R_ARROW;
            end
            else if(CODEWORD == ALT_CODE) begin
                if(BREAK) begin
                    L_ALT_nxt = 0;
                end
                else begin
                    L_ALT_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;  
            end
            else if(CODEWORD == CTRL_CODE) begin
                if(BREAK) begin
                    L_CTRL_nxt = 0;
                end
                else begin
                    L_CTRL_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;   
            end
            else if(CODEWORD == L_SHIFT_CODE) begin
                if(BREAK) begin
                    L_SHIFT_nxt = 0;
                end
                else begin
                    L_SHIFT_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end
            else if(CODEWORD == R_SHIFT_CODE) begin
                if(BREAK) begin
                    R_SHIFT_nxt = 0;
                end
                else begin
                    R_SHIFT_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end
            else if(CODEWORD == SPACE_CODE) begin
                if(BREAK) begin
                    SPACE_nxt = 0;
                end
                else begin
                    SPACE_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end 
            else if(CODEWORD == ESC_CODE) begin
                if(BREAK) begin
                    ESC_nxt = 0;
                end
                else begin
                    ESC_nxt = 1;
                end
                EXTENDED_nxt= 0;
                BREAK_nxt 	= 0;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end  
            else begin
                EXTENDED_nxt= EXTENDED;
                BREAK_nxt 	= BREAK;
                L_ALT_nxt 	= L_ALT;
                R_ALT_nxt 	= R_ALT;
                L_CTRL_nxt 	= L_CTRL;
                R_CTRL_nxt 	= R_CTRL;
                L_SHIFT_nxt = L_SHIFT;
                R_SHIFT_nxt = R_SHIFT;
                SPACE_nxt 	= SPACE;
                ESC_nxt 	= ESC;
                D_ARROW_nxt = D_ARROW;
                L_ARROW_nxt = L_ARROW;
                R_ARROW_nxt = R_ARROW;
            end
        end
        else begin
            EXTENDED_nxt= 0;
            BREAK_nxt   = 0;
            L_ALT_nxt   = L_ALT;
            R_ALT_nxt   = R_ALT;
            L_CTRL_nxt  = L_CTRL;
            R_CTRL_nxt  = R_CTRL;
            L_SHIFT_nxt = L_SHIFT;
            R_SHIFT_nxt = R_SHIFT;
            SPACE_nxt   = SPACE;
            ESC_nxt     = ESC;
            D_ARROW_nxt = D_ARROW;
            L_ARROW_nxt = L_ARROW;
            R_ARROW_nxt = R_ARROW;    
        end
    end
	
endmodule