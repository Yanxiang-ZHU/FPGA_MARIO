`timescale 1ns / 1ps

module MarioScore24x1 (
        input wire  [7:0] char_xy,
		input wire  [3:0] mario_lives,
		input wire  [3:0] level,
		input wire  [11:0] coins,

        output wire [7:0] char_code    
    );

    reg [7:0] char_code_nxt;
	reg [3:0] bcd0, bcd1, bcd2;
	reg [3:0] hex1, hex2, hex3, hex4, hex5;

	integer i;

    always @(coins)
    begin
        bcd0 = 0;
        bcd1 = 0;
        bcd2 = 0;

        for ( i = 11; i >= 0; i = i - 1 )
        begin
            if( bcd0 > 4 ) bcd0 = bcd0 + 3;
            if( bcd1 > 4 ) bcd1 = bcd1 + 3;
            if( bcd2 > 4 ) bcd2 = bcd2 + 3;
            { bcd2[3:0], bcd1[3:0], bcd0[3:0] } =
            { bcd2[2:0], bcd1[3:0], bcd0[3:0],coins[i] };
        end
    end
	
	always @(*)
	begin
		case(mario_lives)
			0: hex1 = 8'h00;
			1: hex1 = 8'h01;
			2: hex1 = 8'h02;
			3: hex1 = 8'h03;
			4: hex1 = 8'h04;
			5: hex1 = 8'h05;
			6: hex1 = 8'h06;
			7: hex1 = 8'h07;
			8: hex1 = 8'h08;
			9: hex1 = 8'h09;
			default: hex1 = 8'h00;
		endcase
		
		case(level)
			0: hex2 = 8'h00;
			1: hex2 = 8'h01;
			2: hex2 = 8'h02;
			3: hex2 = 8'h03;
			4: hex2 = 8'h04;
			5: hex2 = 8'h05;
			6: hex2 = 8'h06;
			7: hex2 = 8'h07;
			8: hex2 = 8'h08;
			9: hex2 = 8'h09;
			default: hex2 = 8'h00;
		endcase
		
		case(bcd0)
			0: hex3 = 8'h00;
			1: hex3 = 8'h01;
			2: hex3 = 8'h02;
			3: hex3 = 8'h03;
			4: hex3 = 8'h04;
			5: hex3 = 8'h05;
			6: hex3 = 8'h06;
			7: hex3 = 8'h07;
			8: hex3 = 8'h08;
			9: hex3 = 8'h09;
			default: hex3 = 8'h00;
		endcase

		case(bcd1)
			0: hex4 = 8'h00;
			1: hex4 = 8'h01;
			2: hex4 = 8'h02;
			3: hex4 = 8'h03;
			4: hex4 = 8'h04;
			5: hex4 = 8'h05;
			6: hex4 = 8'h06;
			7: hex4 = 8'h07;
			8: hex4 = 8'h08;
			9: hex4 = 8'h09;
			default: hex4 = 8'h00;
		endcase

		case(bcd2)
			0: hex5 = 8'h00;
			1: hex5 = 8'h01;
			2: hex5 = 8'h02;
			3: hex5 = 8'h03;
			4: hex5 = 8'h04;
			5: hex5 = 8'h05;
			6: hex5 = 8'h06;
			7: hex5 = 8'h07;
			8: hex5 = 8'h08;
			9: hex5 = 8'h09;
			default: hex5 = 8'h00;
		endcase
	end


    always @* begin
        case(char_xy)
		8'h00: 	char_code_nxt = 8'h0A; // M
		8'h01:	char_code_nxt = 8'h0B; // A
		8'h02:  char_code_nxt = 8'h0C; // R
		8'h03:  char_code_nxt = 8'h0D; // I
		8'h04:  char_code_nxt = 8'h0E; // O
		8'h05:  char_code_nxt = 8'h0F; // 
		8'h06:  char_code_nxt = 8'h10; // x
		8'h07:  char_code_nxt = hex1;  // liczba zyc
		8'h08:  char_code_nxt = 8'h0F; // 
		8'h09:  char_code_nxt = 8'h0F; // 
		8'h0a:  char_code_nxt = 8'h0F; // 
		8'h0b:  char_code_nxt = 8'h0F; // 
		8'h0c:  char_code_nxt = 8'h0F; // 
		8'h0d:  char_code_nxt = 8'h0F; // 
        8'h0e:  char_code_nxt = 8'h0F; // 
        8'h0f:  char_code_nxt = 8'h0F; // 
        8'h10:  char_code_nxt = 8'h0F; // 
        8'h11:  char_code_nxt = 8'h0F; // 
        8'h12:  char_code_nxt = 8'h0F; // 
        8'h13:  char_code_nxt = 8'h0F; // 
        8'h14:  char_code_nxt = 8'h0F; // 
        8'h15:  char_code_nxt = 8'h0F; // 
        8'h16:  char_code_nxt = 8'h0F; // 
        8'h17:  char_code_nxt = 8'h0F; // 
        8'h18:  char_code_nxt = 8'h0F; // 
        8'h19:  char_code_nxt = 8'h0F; // 
        8'h1a:  char_code_nxt = 8'h0F; // 
        8'h1b:  char_code_nxt = 8'h0F; // 
        8'h1c:  char_code_nxt = 8'h0F; // 
        8'h1d:  char_code_nxt = 8'h0F; // 
        
		8'h1e:  char_code_nxt = 8'h0F; //
		8'h1f:  char_code_nxt = 8'h0F; // 
		8'h20:  char_code_nxt = 8'h11; // moneta
		8'h21:  char_code_nxt = 8'h0F; // 
		8'h22:  char_code_nxt = 8'h10; // x	
		8'h23:  char_code_nxt = hex5;  // liczba monet		
		8'h24:  char_code_nxt = hex4;  // liczba monet	
		8'h25:  char_code_nxt = hex3;  // liczba monet	
		8'h26:  char_code_nxt = 8'h0F; // 
        8'h27:  char_code_nxt = 8'h0F; // 
        8'h28:  char_code_nxt = 8'h0F; // 
        8'h29:  char_code_nxt = 8'h0F; // 
        8'h2a:  char_code_nxt = 8'h0F; // 
        8'h2b:  char_code_nxt = 8'h0F; // 
        8'h2c:  char_code_nxt = 8'h0F; // 
        8'h2d:  char_code_nxt = 8'h0F; // 
        8'h2e:  char_code_nxt = 8'h0F; // 
        8'h2f:  char_code_nxt = 8'h0F; // 
        8'h30:  char_code_nxt = 8'h0F; // 
        8'h31:  char_code_nxt = 8'h0F; // 
        8'h32:  char_code_nxt = 8'h0F; // 
        8'h33:  char_code_nxt = 8'h0F; // 
        8'h34:  char_code_nxt = 8'h0F; // 
        8'h35:  char_code_nxt = 8'h0F; // 
        8'h36:  char_code_nxt = 8'h0F; // 
        8'h37:  char_code_nxt = 8'h0F; // 
        8'h38:  char_code_nxt = 8'h0F; // 
        8'h39:  char_code_nxt = 8'h0F; // 
        8'h3a:  char_code_nxt = 8'h0F; // 
        8'h3b:  char_code_nxt = 8'h0F; // 


		8'h3c:  char_code_nxt = 8'h0F; //
		8'h3d:  char_code_nxt = 8'h0F; //
		8'h3e:  char_code_nxt = 8'h12; // L
		8'h3f:  char_code_nxt = 8'h13; // E
		8'h40:  char_code_nxt = 8'h14; // V
		8'h41:  char_code_nxt = 8'h13; // E
		8'h42:  char_code_nxt = 8'h12; // L
		8'h43:  char_code_nxt = 8'h0F; // 
		8'h44:  char_code_nxt = hex2;  // numer levelu

		default: char_code_nxt = 8'hff;
		endcase
	end

    assign char_code = char_code_nxt;

endmodule
