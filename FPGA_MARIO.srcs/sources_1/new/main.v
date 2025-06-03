`timescale 1 ns / 1 ps

module main (
  	input wire clk,
	input wire btnC,
  	input wire PS2Clk,
  	input wire PS2Data,
    input wire ctrl,
    input wire space,
    input wire shift,
    input wire esc,
    input wire d_arrow,
    input wire l_arrow,
    input wire r_arrow,
  
    output wire speaker,
  	output wire [3:0] vgaRed,
  	output wire [3:0] vgaGreen,
  	output wire [3:0] vgaBlue,
  	output wire vga2Hsync,
  	output wire vga2Vsync,
  	output wire debug_light
  	);
  	
  	wire alt;
  	assign debug_light = alt;
  	wire [7:0] vga2Red;
  	wire [7:0] vga2Green;
  	wire [7:0] vga2Blue;
  	wire vga2Blank;
  	wire vga2Clk;
  	assign vgaRed = vga2Red[7:4];
  	assign vgaGreen = vga2Green[7:4];
  	assign vgaBlue = vga2Blue[7:4];
  	
  	assign vga2Clk = clk_25M;
  	wire l_alt, r_alt, l_ctrl, r_ctrl, l_shift, r_shift;
  	assign l_alt = alt;
  	assign r_alt = alt;
  	assign l_ctrl = ctrl;
  	assign r_ctrl = ctrl;
  	assign l_shift = shift;
  	assign r_shift = shift;
  	
  	wire rst;
  	assign rst = btnC;
    
    //Clocks generation
    wire clk_25M, clk_100M, clk_600, clk_100k, locked;
    
    clk_wiz_0 clk_wiz_0_u(
        .clk_in1(clk),
        .reset(rst),
        
        .clk_out1(clk_25M),
        .clk_out2(clk_100M),
        .locked(locked)
    );
    
    clk_divider #(.FREQ(200000)) keyboard_clk_divider (
            .clk100MHz(clk_100M), 
            .rst(rst),       
            
            .clk_div(clk_100k)    
        );
    
  	clk_divider #(.FREQ(600)) game_clk_divider (
        .clk100MHz(clk_100M), 
        .rst(rst),       
        
        .clk_div(clk_600)    
    );
    
    clk_divider #(.FREQ(50000000)) board_divider (
        .clk100MHz(clk_100M), 
        .rst(rst),       
        
        .clk_div(clk_50M)    
    );
    
    wire [10:0] rom_addr;
    wire [23:0] rom_data;
    
     //End of clock generation

    wire [9:0] bcgr_xpos;
    
    wire [9:0] hcount, hcount_out_bg, hcount_out_brd, hcount_out_player, hcount_out_monster_1, hcount_out_score, hcount_out;
    wire [9:0] vcount, vcount_out_bg, vcount_out_brd, vcount_out_player, vcount_out_monster_1, vcount_out_score, vcount_out;
    wire hsync, hsync_out_bg, hsync_out_brd, hsync_out_player, hsync_out_score, hsync_out_gameover;
    wire vsync, vsync_out_bg, vsync_out_brd, vsync_out_player, vsync_out_score, vsync_out_gameover;
    wire blnk, blnk_out_bg, blnk_out_brd, blnk_out_player, blnk_out_score, blnk_out_gameover, blnk_out;
    wire [23:0] rgb_out_bg, rgb_out_brd, rgb_out_player, rgb_out_monster_1, rgb_out_score, rgb_out_gameover;
    
    wire [9:0] mario_x, monster_1_x;
    wire [8:0] mario_y, monster_1_y;
    
    wire [5:0] plane_xpos_ofs;
    wire [7:0]  plane_xpos;
    wire [3:0]  plane_ypos;
    wire [15:0] blocking_player;
    wire mario_dir, blocking, monster_1_dir;
    wire [5:0] block_display;
    
    wire [7:0] engine_xpos, block_display_xpos;
    wire [3:0] engine_ypos, block_display_ypos;
    wire [5:0] engine_write_block, engine_block;
  
  	VgaTiming VgaTiming_u (
	    .pclk(clk_25M),
	    .rst(rst),

	    .hcount(hcount),
	    .hsync(hsync),   
	    .vcount(vcount),
	    .vsync(vsync),
	    .blnk(blnk)
  	);

//*********BEGINING OF GRAPHICS********

  	DrawBackground DrawBackground_u (
	    .hcount_in(hcount),
	    .hsync_in(hsync),  
	    .vcount_in(vcount),
	    .vsync_in(vsync),
	    .blnk_in(blnk),
	    .xoffset(bcgr_xpos),
	    .clk(clk_25M),
	    .rst(rst),
	    
	    .hcount_out(hcount_out_bg),
	    .hsync_out(hsync_out_bg),
	    .vcount_out(vcount_out_bg),
	    .vsync_out(vsync_out_bg), 
	    .rgb_out(rgb_out_bg),
	    .blnk_out(blnk_out_bg)
  	);

    Board Board_u (
        .hcount_in(hcount_out_bg),
        .hsync_in(hsync_out_bg),
        .vcount_in(vcount_out_bg),
        .vsync_in(vsync_out_bg),
        .rgb_in(rgb_out_bg),
        .blnk_in(blnk_out_bg), 
        .plane_xpos(plane_xpos),
        .plane_xpos_ofs(plane_xpos_ofs),
        .block(block_display),
        .pclk(clk_25M),
        .clk(clk_50M),
        .rst(rst),
        
        .block_xpos(block_display_xpos),
        .block_ypos(block_display_ypos),
	    .hcount_out(hcount_out_brd),
        .hsync_out(hsync_out_brd),
        .vcount_out(vcount_out_brd),
        .vsync_out(vsync_out_brd),    
        .rgb_out(rgb_out_brd),
        .blnk_out(blnk_out_brd)
    );
    
    Player Player_u (
        .hcount_in(hcount_out_brd),
        .hsync_in(hsync_out_brd),
        .vcount_in(vcount_out_brd),
        .vsync_in(vsync_out_brd),
        .rgb_in(rgb_out_brd),
        .blnk_in(blnk_out_brd),
        .xpos(mario_x),
        .ypos(mario_y),
        .direction(mario_dir),
        .size(0),
        .fire(0),
        .clk(clk_25M),
        .rst(rst),
        .rom_data(rom_data),

        .rom_addr(rom_addr),
        .hcount_out(hcount_out_player),
        .hsync_out(hsync_out_player),
        .vcount_out(vcount_out_player),
        .vsync_out(vsync_out_player),
        .rgb_out(rgb_out_player),
        .blnk_out(blnk_out_player)
      );
    
    DrawMarioScore DrawMarioScore_u(
        .clk(clk_25M),
        .rst(rst),
        .hcount_in(hcount_out_player),
        .hsync_in(hsync_out_player),
        .vcount_in(vcount_out_player),
        .vsync_in(vsync_out_player),
        .rgb_in(rgb_out_player),
        .blnk_in(blnk_out_player),
        .char_pixels(char_line_pixels),
        
        .hcount_out(hcount_out_score),
        .hsync_out(hsync_out_score),
        .vcount_out(vcount_out_score),
        .vsync_out(vsync_out_score),
        .rgb_out(rgb_out_score),
        .blnk_out(blnk_out_score),
        .char_xy(char_xy),
        .char_line(char_line)
    );
    
    Gameover Gameover_u (
        .hcount_in(hcount_out_score),
        .hsync_in(hsync_out_score),
        .vcount_in(vcount_out_score),
        .vsync_in(vsync_out_score),
        .rgb_in(rgb_out_score),
        .blnk_in(blnk_out_score),
        .gameover(gameover),
        .rst(rst),
        .clk(clk_25M),
    
        .hcount_out(hcount_out),
        .hsync_out(hsync_out_gameover),
        .vcount_out(vcount_out),
        .vsync_out(vsync_out_gameover),
        .rgb_out(rgb_out_gameover),
        .blnk_out(blnk_out_gameover)
    );
    
    Change2Negedge Change2Negedge_u(
        .hsync_in(hsync_out_gameover),
        .vsync_in(vsync_out_gameover),
        .blnk_in(blnk_out_gameover),
        .rgb_in(rgb_out_gameover),
        .clk(clk_25M),
        .rst(rst),
        
        .hsync_out(vga2Hsync),
        .vsync_out(vga2Vsync),
        .blnk_out(vga2Blank),
        .rgb_out({vga2Red,vga2Green,vga2Blue})   
    );


//**********END OF GRAPHICS*********** 

 
//**********GAME CONTROLL*************

    dist_mem_gen_0 mario_picture(
        .a(rom_addr),
        .spo(rom_data)
    );
 
    wire [11:0] fs_ram_a, fs_ram_dpra;
    wire [5:0] fs_ram_d, fs_ram_spo, fs_ram_dpo;
 
    dist_mem_gen_1 first_stage_ram(
        .a(fs_ram_a),
        .d(fs_ram_d),
        .dpra(fs_ram_dpra),
        .clk(clk_100M),
        .we(fs_ram_we),
        .spo(fs_ram_spo),
        .dpo(fs_ram_dpo)
    );
   
   wire [11:0] fs_addr_c;
   wire [5:0] fs_data_c;
   
    dist_mem_gen_2 first_stage_rom(
        .a(fs_addr_c),
        .spo(fs_data_c)
    );
     
    wire [7:0] char_line_pixels;
    wire [7:0] char_code;
    wire [3:0] char_line;
    wire [7:0] char_xy;
    wire [3:0] mario_lifes;
    wire [11:0] player_points;
    wire [3:0] lvl_number;
     
    MarioFontRom MarioFontRom_u(
        .addr({char_code, char_line}),
        .char_line_pixels(char_line_pixels)
    );
     
    MarioScore24x1 MarioScore24x1_u(
        .char_xy(char_xy),
        .mario_lives(mario_lifes),
        .level(lvl_number),
        .coins(player_points),
             
        .char_code(char_code)    
    );
     
    //Music
    Music Music_u(
        .clk(clk_25M),
        .speaker(speaker)
    );

    FirstStage Engine_FirstStage(
        .plane_xpos(engine_xpos),
        .plane_ypos(engine_ypos),
        .ram_read_data(fs_ram_spo),
        .write_block(engine_write_block),
        .save_block(engine_we),
        .copy_backup(stage_restart),
        .copy_read_data(fs_data_c),
        .clk(clk_100M),
        .rst(rst),

        .blocking(engine_blocking),
        .block(engine_block),
        .ram_addr(fs_ram_a),
        .ram_write_data(fs_ram_d),
        .ram_we(fs_ram_we),
        .copy_addr(fs_addr_c),
        .backuped(stage_restarted)    
    );
    
    FirstStage Display_FirstStage(
        .plane_xpos(block_display_xpos),
        .plane_ypos(block_display_ypos),
        .ram_read_data(fs_ram_dpo),
        .save_block(0),
        .copy_backup(0),

        .block(block_display),
        .ram_addr(fs_ram_dpra)
    );
    
    wire [1:0] player_speed;
    GameEngine GameEngine_u(
        .clk(clk_25M),
        .game_clk(clk_600),
        .rst(rst),
        .L_ALT(l_alt),
        .R_ALT(r_alt),
        .L_CTRL(l_ctrl),
        .R_CTRL(r_ctrl),
        .SPACE(space),
        .L_SHIFT(l_shift),
        .R_SHIFT(r_shift),
        .ESC(esc),
        .D_ARROW(d_arrow),
        .L_ARROW(l_arrow),
        .R_ARROW(r_arrow),
        .blocking_in(engine_blocking),
        .block_in(engine_block),
        .gameover(gameover),
        .stage_restarted(stage_restarted),
        
        .block_xpos(engine_xpos),
        .block_ypos(engine_ypos),
        .player_xpos(mario_x),
        .player_ypos(mario_y),
        .bcgr_xpos(bcgr_xpos),
        .plane_xpos(plane_xpos),
        .plane_xpos_ofs(plane_xpos_ofs),
        .player_dir(mario_dir),
        .player_speed(player_speed),
        .player_life(mario_lifes),
        .player_points(player_points),
        .lvl_number(lvl_number),
        .write_block(engine_write_block),
        .block_we(engine_we),
        .restartgame(stage_restart)
    );
//******END OF GAME CONTROLL******
 
//*********PHERIPERALS************
    mouse_basys3_FPGA Mouse (
        .clock_100Mhz(clk_100M),
        .reset(rst),
        .Mouse_Data(PS2Clk),
        .Mouse_Clk(PS2Data),
//        .left_button(l_arrow),
//        .right_button(r_arrow),
        .middle_button(alt)
    );
//    Keyboard my_Keyboard(
//        .CLK(clk_100k),
//        .rst(rst),
//        .PS2_CLK(PS2Clk),
//        .PS2_DATA(PS2Data),

//        .L_ALT(l_alt),
//        .R_ALT(r_alt),
//        .L_CTRL(l_ctrl),
//        .R_CTRL(r_ctrl),
//        .SPACE(space),
//        .L_SHIFT(l_shift),
//        .R_SHIFT(r_shift),
//        .ESC(esc),
//        .D_ARROW(d_arrow),
//        .L_ARROW(l_arrow),
//        .R_ARROW(r_arrow)
//    );

endmodule