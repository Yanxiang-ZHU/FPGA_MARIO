`timescale 1 ns / 1 ps

module GameEngine
(
    input wire clk,
    input wire game_clk,
    input wire rst,
	input wire L_ALT,
    input wire R_ALT,
    input wire L_CTRL,
    input wire R_CTRL,
    input wire SPACE,
    input wire L_SHIFT,
    input wire R_SHIFT,
    input wire ESC,
    input wire D_ARROW,
    input wire L_ARROW,
    input wire R_ARROW,
    input wire blocking_in,
    input wire [5:0] block_in,
    input wire stage_restarted,
    
    output reg [7:0] block_xpos,
    output reg [3:0] block_ypos,
    output reg [9:0] bcgr_xpos,
    output reg [7:0] plane_xpos,
    output reg [5:0] plane_xpos_ofs,
    output reg [9:0] player_xpos,
    output reg [8:0] player_ypos,
    output reg player_dir,
    output reg monster_1_dir,
    output reg [1:0] player_speed,
    output reg gameover,
    output reg [5:0] write_block,
    output reg block_we,
    output reg restartgame,
    output reg [3:0] player_life,
    output reg [11:0] player_points,
    output reg [3:0] lvl_number
 );
    
    always @(posedge clk) begin
        lvl_number <=1 ;
    end
    
    reg gameover_nxt;
    reg restartgame_nxt;
    reg player_xpos_restarted;
    reg player_ypos_restarted;
    reg bcgr_restarted;
    reg board_restarted;
    reg player_xpos_restarted_nxt;
    reg player_ypos_restarted_nxt;
    reg bcgr_restarted_nxt;
    reg board_restarted_nxt;
    //************************
    //State Machine for player
    //************************
    
    reg [3:0] player_life_nxt;
    reg [1:0] player_hor_state;
    reg [1:0] player_ver_state;
    reg [1:0] player_hor_state_nxt;
    reg [1:0] player_ver_state_nxt;
    reg [7:0] jump_height;
    reg [7:0] jump_height_nxt;
    reg [9:0] player_xpos_nxt;
    reg [8:0] player_ypos_nxt;
    reg player_dir_nxt;
    reg [1:0] player_speed_nxt;
    localparam PL_STOP = 2'b00;
    localparam PL_RIGHT = 2'b01;
    localparam PL_LEFT = 2'b10;
    localparam PL_JUMP = 2'b01;
    localparam PL_FALL = 2'b10;
    localparam DIR_RIGHT = 1'b0;
    localparam DIR_LEFT = 1'b1;
    localparam PL_STAND = 2'b00;
    localparam PL_WALK = 2'b01;
    localparam PL_RUN = 2'b10;
    localparam PLAYER_WIDTH = 40;
    localparam PLAYER_XPOS_MAX = 480;
    localparam PLAYER_XPOS_MIN = 120;
    localparam PLAYER_YPOS_MAX = 480;
   
   //Speed
    always @* begin
        if(L_ARROW || R_ARROW) begin
            if(L_CTRL || R_CTRL)
                player_speed_nxt = PL_RUN;
            else 
                player_speed_nxt = PL_WALK;
        end
        else
            player_speed_nxt = PL_STAND;
    end
    
    //Lifes
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            player_life <= 3;
            gameover <= 0;
            restartgame <= 0;
        end
        else begin
            player_life <= player_life_nxt;
            gameover <= gameover_nxt;
            restartgame <= restartgame_nxt;
        end
    end
    
    reg [11:0] player_points_nxt;
    reg [11:0] player_points_latched;
    reg [11:0] player_points_latched_nxt;
    
    //Points
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            player_points <= 0;
            player_points_latched <= 0;
        end 
        else begin
            player_points <= player_points_nxt;//player_points_nxt;
            player_points_latched <= player_points_latched_nxt;
        end
    end
    
    always @* begin
        if((new_point) && (player_points_latched == player_points)) begin
            player_points_nxt = player_points + 1;
            player_points_latched_nxt = player_points_latched;
        end
        else begin
            player_points_nxt = player_points;
            if(new_point)
                player_points_latched_nxt = player_points_latched;
            else    
                player_points_latched_nxt = player_points;
        end
    end
    
    //loosing lifes, gameover
    always @* begin
        if(gameover) begin
            restartgame_nxt = 1;
            player_life_nxt = 0;
            gameover_nxt = 1;
        end
        else if(restartgame) begin
            if((player_xpos_restarted) && (player_ypos_restarted) && (board_restarted) && (bcgr_restarted) && (stage_restarted)) begin
                restartgame_nxt = 0;
                player_life_nxt = player_life;
                gameover_nxt = gameover;
            end
            else begin
                restartgame_nxt = 1;
                player_life_nxt = player_life;
                gameover_nxt = gameover;
            end
        end
        else if(player_ypos == 0) begin
            if(player_life == 1) begin
                gameover_nxt = 1;
                player_life_nxt = 0;
                restartgame_nxt = 1;
            end
            else begin
                player_life_nxt = player_life - 1;
                gameover_nxt = 0;
                restartgame_nxt = 1;
            end
        end
        else begin
            gameover_nxt = 0;
            player_life_nxt = player_life;
            restartgame_nxt = 0;
        end
    end
   
    //Player horizontal movement
    always @* begin
        if(restartgame) begin
            player_xpos_nxt     = 120;
            player_hor_state_nxt= 0;
            player_dir_nxt      = 0;
            player_xpos_restarted_nxt = 1;
        end
        else begin
            player_xpos_restarted_nxt = 0;
            case(player_hor_state)
                PL_STOP: begin
                    if(L_ARROW) begin
                        if(blocking[1]) player_hor_state_nxt = PL_STOP;
                        else player_hor_state_nxt = PL_LEFT;
                    end
                    else if(R_ARROW) begin
                        if(blocking[0]) player_hor_state_nxt = PL_STOP;
                        else player_hor_state_nxt = PL_RIGHT;
                    end
                    else begin
                        player_hor_state_nxt = PL_STOP;
                    end
                    player_xpos_nxt = player_xpos;
                    player_dir_nxt = player_dir;
                end
                PL_RIGHT: begin
                    if(L_ARROW) begin
                        if(blocking[1]) player_hor_state_nxt = PL_STOP;
                        else player_hor_state_nxt = PL_LEFT;
                    end
                    else if(R_ARROW) begin
                        if(blocking[0]) player_hor_state_nxt = PL_STOP;
                        else player_hor_state_nxt = PL_RIGHT;
                    end
                    else begin
                        player_hor_state_nxt = PL_STOP;
                    end
                    if(((player_xpos) < PLAYER_XPOS_MAX)&&(blocking[0]==0)) begin
                        player_xpos_nxt = player_xpos + 1;
                        player_dir_nxt = DIR_RIGHT;
                    end
                    else begin
                        player_xpos_nxt = player_xpos;
                        player_dir_nxt = DIR_RIGHT;
                    end
                end
                PL_LEFT: begin
                    if(L_ARROW) begin
                        if(blocking[1]) player_hor_state_nxt = PL_STOP;
                        else player_hor_state_nxt = PL_LEFT;
                    end
                    else if(R_ARROW) begin
                        if(blocking[0]) player_hor_state_nxt = PL_STOP;
                        else player_hor_state_nxt = PL_RIGHT;
                    end
                    else begin
                        player_hor_state_nxt = PL_STOP;
                    end
                    if(((player_xpos) > PLAYER_XPOS_MIN)&&(blocking[1] == 0)) begin
                        player_xpos_nxt = player_xpos - 1;
                        player_dir_nxt = DIR_LEFT;  
                    end
                    else begin
                        player_xpos_nxt = player_xpos;
                        player_dir_nxt = DIR_LEFT;
                    end
                end
                default: begin
                    player_hor_state_nxt = PL_STOP;
                    player_xpos_nxt = player_xpos;
                    player_dir_nxt = player_dir;
                end
            endcase
        end
    end
    
    //Player vertical movement
    always @* begin
        if(restartgame) begin
            player_ypos_nxt     = 100;
            player_ver_state_nxt= 0;
            jump_height_nxt     = 0;
            player_ypos_restarted_nxt = 1;
        end
        else begin
        player_ypos_restarted_nxt = 0;
            case(player_ver_state)
                PL_STOP: begin
                    if(L_ALT || R_ALT) begin
                        if(blocking[2]) 
                            player_ver_state_nxt = PL_STOP;
                        else 
                            player_ver_state_nxt = PL_JUMP;
                    end
                    else if(blocking[3] == 0)
                        player_ver_state_nxt = PL_FALL;
                    else
                        player_ver_state_nxt = PL_STOP;
                    
                    player_ypos_nxt = player_ypos;
                    jump_height_nxt = 0;
                end
                PL_JUMP: begin
                    if((jump_height < 200) && (blocking[2] == 0)) begin
                        player_ver_state_nxt = PL_JUMP;
                        jump_height_nxt = jump_height + 1;
                        if(player_ypos == PLAYER_YPOS_MAX)
                            player_ypos_nxt = player_ypos;
                        else
                            player_ypos_nxt = player_ypos + 1;
                    end
                    else begin
                        player_ver_state_nxt = PL_FALL;
                        jump_height_nxt = jump_height;
                        player_ypos_nxt = player_ypos;
                    end
                end
                PL_FALL: begin
                    if((blocking[3] == 0)) begin
                        player_ver_state_nxt = PL_FALL;
                        jump_height_nxt = jump_height - 1;
                        player_ypos_nxt = player_ypos - 1;
                    end
                    else begin
                        player_ver_state_nxt = PL_STOP;
                        jump_height_nxt = jump_height;
                        player_ypos_nxt = player_ypos;
                    end        
                end
                default: begin
                    player_ver_state_nxt = PL_STOP;
                    jump_height_nxt = jump_height;
                    player_ypos_nxt = player_ypos;
                end
            endcase
        end
    end
    
    always @(posedge game_clk or posedge rst) begin
        if(rst) begin
            player_ypos     <= 100;
            player_ver_state<= 0;
            jump_height     <= 0;
            player_ypos_restarted <= 0;
        end
        else begin
            player_ypos     <= player_ypos_nxt;
            player_ver_state<= player_ver_state_nxt;
            jump_height     <= jump_height_nxt;
            player_ypos_restarted <= player_ypos_restarted_nxt;
        end
    end
    
    reg [1:0] clk_hor_divider;
    always @(posedge game_clk or posedge rst) begin
        if(rst) begin
            player_xpos_restarted <= 0;
            player_xpos     <= 120;
            player_hor_state<= 0;
            player_dir      <= 0;
            clk_hor_divider <= 2'b00;
        end
        else begin
            if((clk_hor_divider == 2'b01)&&(player_speed == PL_RUN)) begin
                player_xpos     <= player_xpos_nxt;
                player_hor_state<= player_hor_state_nxt;
                player_dir      <= player_dir_nxt;
                clk_hor_divider <= 2'b10;
                player_xpos_restarted <= 0;
            end
            else if(clk_hor_divider == 2'b11) begin
                player_xpos     <= player_xpos_nxt;
                player_hor_state<= player_hor_state_nxt;
                player_dir      <= player_dir_nxt;
                clk_hor_divider <= 2'b00;
                player_xpos_restarted <= player_xpos_restarted_nxt;
            end
            else
                clk_hor_divider <= clk_hor_divider + 1;
        end
    end
    
    always @(posedge game_clk or posedge rst) begin
        if(rst)
            player_speed    <= PL_STOP;
        else
            if(clk_hor_divider == 2'b11)
                player_speed    <= player_speed_nxt;
    end
    //********************************
    // End of State Machine for player
    //********************************
       
        
    //************************************************
    // State Machine for board and background movement (uses player states because depends on player movement)
    //************************************************
    reg [9:0] bcgr_xpos_nxt;
    localparam XRES = 640;
    
    always @* begin
        if(restartgame) begin
            bcgr_xpos_nxt = 0;
            bcgr_restarted_nxt = 1;
        end
        else begin
        bcgr_restarted_nxt = 0;
            case(player_hor_state)
                PL_STOP:
                    bcgr_xpos_nxt = bcgr_xpos;
                PL_RIGHT:
                    if((player_xpos == PLAYER_XPOS_MAX)&&((plane_xpos_ofs != MAX_OFFSET)||(plane_xpos != BOARD_END)))
                        bcgr_xpos_nxt = (bcgr_xpos + 2*player_speed) % (XRES - 1);
                    else
                        bcgr_xpos_nxt = bcgr_xpos;
                PL_LEFT:
                    if((player_xpos == PLAYER_XPOS_MIN)&&((plane_xpos_ofs != 0)||(plane_xpos != 0)))    
                        if(bcgr_xpos < 2*player_speed)
                            bcgr_xpos_nxt = ((XRES-1) + bcgr_xpos - 2*player_speed);
                        else
                            bcgr_xpos_nxt = bcgr_xpos - 2*player_speed;
                    else
                       bcgr_xpos_nxt = bcgr_xpos;
                default:
                    bcgr_xpos_nxt = bcgr_xpos;
            endcase
        end
    end
    
    reg [7:0] plane_xpos_nxt;
    reg [5:0] plane_xpos_ofs_nxt;
    localparam MAX_OFFSET = 39;
    localparam BOARD_END = 163;
    
    always @* begin
        if(restartgame) begin
            plane_xpos_ofs_nxt = 0;
            plane_xpos_nxt = 0;
            board_restarted_nxt = 1;
        end
        else begin
            board_restarted_nxt = 0;
            case(player_hor_state)
                PL_STOP: begin
                    plane_xpos_ofs_nxt = plane_xpos_ofs;
                    plane_xpos_nxt = plane_xpos;
                end
                PL_RIGHT:
                    if(player_xpos == PLAYER_XPOS_MAX) begin
                        if(blocking[0] == 0) begin
                            if(plane_xpos_ofs == MAX_OFFSET) begin
                                if(plane_xpos == BOARD_END) begin
                                    plane_xpos_ofs_nxt = MAX_OFFSET;
                                    plane_xpos_nxt = BOARD_END;
                                end
                                else begin
                                    plane_xpos_ofs_nxt = 0;
                                    plane_xpos_nxt = plane_xpos + 1;
                                end
                            end
                            else begin
                                plane_xpos_ofs_nxt = plane_xpos_ofs + 1;
                                plane_xpos_nxt = plane_xpos;
                            end
                        end
                        else begin
                            plane_xpos_ofs_nxt = plane_xpos_ofs;
                            plane_xpos_nxt = plane_xpos;
                        end
                    end
                    else begin
                        plane_xpos_ofs_nxt = plane_xpos_ofs;
                        plane_xpos_nxt = plane_xpos;
                    end
                PL_LEFT: begin
                    if(player_xpos == PLAYER_XPOS_MIN) begin   
                        if(blocking[1] == 0) begin
                            if(plane_xpos_ofs == 0) begin
                                if(plane_xpos == 0) begin
                                    plane_xpos_ofs_nxt = 0;
                                    plane_xpos_nxt = 0;
                                end
                                else begin
                                    plane_xpos_ofs_nxt = MAX_OFFSET;
                                    plane_xpos_nxt = plane_xpos - 1;
                                end
                            end
                            else begin
                                plane_xpos_ofs_nxt = plane_xpos_ofs - 1;
                                plane_xpos_nxt = plane_xpos;
                            end
                        end
                        else begin
                            plane_xpos_ofs_nxt = plane_xpos_ofs;
                            plane_xpos_nxt = plane_xpos;
                        end
                    end
                    else begin
                        plane_xpos_ofs_nxt = plane_xpos_ofs;
                        plane_xpos_nxt = plane_xpos;
                    end
                end
                default: begin
                    plane_xpos_ofs_nxt = plane_xpos_ofs;
                    plane_xpos_nxt = plane_xpos;
                end
            endcase
        end
    end
        
    always @(posedge game_clk or posedge rst) begin
        if(rst) begin
            plane_xpos_ofs  <= 0;
            plane_xpos      <= 0;
            board_restarted <= 0;
        end
        else begin
            if((clk_hor_divider == 2'b01)&&(player_speed == PL_RUN)) begin
                plane_xpos_ofs  <= plane_xpos_ofs_nxt;
                plane_xpos      <= plane_xpos_nxt;
                board_restarted <= 0;
            end
            else if(clk_hor_divider == 2'b11) begin
                plane_xpos_ofs  <= plane_xpos_ofs_nxt;
                plane_xpos      <= plane_xpos_nxt;
                board_restarted <= board_restarted_nxt;
            end
        end
    end
    
    always @(posedge game_clk or posedge rst) begin
            if(rst) begin
                bcgr_xpos       <= 0;
                bcgr_restarted <= 0;
            end
            else begin
                if(clk_hor_divider == 2'b11) begin
                    bcgr_xpos       <= bcgr_xpos_nxt;
                    bcgr_restarted <= bcgr_restarted_nxt;
                end
            end
        end
    //**********************************************
    // End of State Machine for board and background
    //**********************************************   
    
    //**********************************************************
    // Logic for blocking the player and checking special blocks
    //**********************************************************
    reg [7:0] block_xpos_nxt;
    reg [3:0] block_ypos_nxt;
    reg [3:0] blocking;//D:U:L:R
    reg [3:0] blocking_nxt;
    reg [47:0] modi_block; //DL:DR:UL:UR:LD:LU:RD:RU
    reg [47:0] modi_block_nxt;
    reg [3:0] blocking_state;
    reg [3:0] blocking_state_nxt;
    reg [1:0] special;
    reg [1:0] special_nxt;
    reg [5:0] write_block_nxt;
    reg block_we_nxt;
    reg [1:0] writing_phase;
    reg [1:0] writing_phase_nxt;
    reg position_changed;
    reg position_changed_nxt;
    localparam SPECIAL      = 2'b01;
    localparam BLOCKING     = 2'b00;
    localparam MOD_BLOCK    = 2'b11;
    localparam PREPARE   = 4'b0000;
    localparam START     = 4'b0001;
    localparam DOWN_L    = 4'b0010;
    localparam DOWN_R    = 4'b0011;
    localparam UP_L      = 4'b0100;
    localparam UP_R      = 4'b0101;
    localparam LEFT_D    = 4'b0110;
    localparam LEFT_U    = 4'b0111;
    localparam RIGHT_D   = 4'b1000;
    localparam RIGHT_U   = 4'b1001;
    
    //position changed
    reg [7:0] old_plane_xpos;
    reg [5:0] old_plane_xpos_ofs;
    reg [9:0] old_player_xpos;
    reg [8:0] old_player_ypos;
    reg [7:0] old_plane_xpos_nxt;
    reg [5:0] old_plane_xpos_ofs_nxt;
    reg [9:0] old_player_xpos_nxt;
    reg [8:0] old_player_ypos_nxt;
    reg position_changed1;
    reg position_changed1_nxt;
    
    always @* begin
        old_plane_xpos_nxt = plane_xpos;
        old_plane_xpos_ofs_nxt = plane_xpos_ofs;
        old_player_xpos_nxt = player_xpos;
        old_player_ypos_nxt = player_ypos;
        if((old_plane_xpos != plane_xpos) || (old_plane_xpos_ofs != plane_xpos_ofs) || (old_player_xpos != player_xpos) || (old_player_ypos != player_ypos))
            position_changed1_nxt = 1;
         else
            position_changed1_nxt = 0;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            old_plane_xpos <= 0;
            old_plane_xpos_ofs <= 0;
            old_player_xpos <= 0;
            old_player_ypos <= 0;
            position_changed1 <= 0;
        end
        else begin
            position_changed1 <= position_changed1_nxt;
            old_plane_xpos <= old_plane_xpos_nxt;
            old_plane_xpos_ofs <= old_plane_xpos_ofs_nxt;
            old_player_xpos <= old_player_xpos_nxt;
            old_player_ypos <= old_player_ypos_nxt;
        end
    end
    
    //rest of blocking
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            special <= 0;
            blocking_state <= PREPARE;
            block_ypos <= 0;
            block_xpos <= 0;
            blocking <= 4'b1000;
            modi_block <= 0;
            write_block <= 0;
            writing_phase <= 2'b00;
            old_block <=0 ;
            position_changed <= 0;
        end
        else begin
            modi_block <= modi_block_nxt;
            special <= special_nxt;
            blocking_state <= blocking_state_nxt;
            block_xpos <= block_xpos_nxt;
            block_ypos <= block_ypos_nxt;
            blocking <= blocking_nxt;
            write_block <= write_block_nxt;
            writing_phase <= writing_phase_nxt;
            old_block <= old_block_nxt;
            position_changed <= position_changed_nxt;
        end
    end
    
    //And here we are, the code below does the job, it really does
    always @* begin
        if(position_changed) begin
        case(special)
            BLOCKING: begin
                left_right_block = 0;
                position_changed_nxt = position_changed;
                up_direction = 0;
                writing_phase_nxt = 2'b00;
                write_block_nxt = 0;
                block_we = 0;
                old_block_nxt = 0;
                modi_block_nxt = modi_block;
                case(blocking_state)
                    PREPARE: begin
                        blocking_state_nxt = START;
                        block_xpos_nxt = plane_xpos + (player_xpos + plane_xpos_ofs)/40;
                        block_ypos_nxt = player_ypos/40;
                        blocking_nxt = blocking;
                        special_nxt = BLOCKING;
                    end
                    START: begin
                        blocking_state_nxt = DOWN_L;
                        block_xpos_nxt = block_xpos;
                        block_ypos_nxt = block_ypos - 1;
                        blocking_nxt = blocking;
                        special_nxt = BLOCKING;
                    end
                    DOWN_L: begin 
                        special_nxt = BLOCKING;
                        if((player_xpos + plane_xpos_ofs)%40 == 0) begin
                            blocking_state_nxt = UP_L;
                            block_xpos_nxt = block_xpos;
                            block_ypos_nxt = block_ypos + 2;
                        end
                        else begin
                            block_xpos_nxt = block_xpos + 1;
                            block_ypos_nxt = block_ypos;
                            blocking_state_nxt = DOWN_R;
                        end
                        if(player_ypos % 40 == 0)
                            blocking_nxt[3] = blocking_in;
                        else
                            blocking_nxt[3] = 0;
                            
                        blocking_nxt[2] = blocking[2];
                        blocking_nxt[1] = blocking[1];
                        blocking_nxt[0] = blocking[0];
                    end
                    DOWN_R: begin
                        special_nxt = BLOCKING;
                        blocking_state_nxt = UP_L;    
                        block_xpos_nxt = block_xpos - 1;
                        block_ypos_nxt = block_ypos + 2;
                        if(player_ypos % 40 == 0)
                            blocking_nxt[3] = (blocking_in || blocking[3]);
                        else
                            blocking_nxt[3] = 0;
                            
                        blocking_nxt[2] = blocking[2];
                        blocking_nxt[1] = blocking[1];
                        blocking_nxt[0] = blocking[0];
                    end
                    UP_L: begin
                        special_nxt = BLOCKING;
                        if((player_xpos + plane_xpos_ofs)%40 == 0) begin
                            blocking_state_nxt = LEFT_D;
                            block_xpos_nxt = block_xpos - 1;
                            block_ypos_nxt = block_ypos - 1;
                        end
                        else begin
                            block_xpos_nxt = block_xpos + 1;
                            blocking_state_nxt = UP_R;
                            block_ypos_nxt = block_ypos;
                        end
                        
                        blocking_nxt[3] = blocking[3];
                        if(player_ypos % 40 == 0)
                            blocking_nxt[2] = blocking_in;
                        else
                            blocking_nxt[2] = 0;
                            
                        blocking_nxt[1] = blocking[1];
                        blocking_nxt[0] = blocking[0];
                    end
                    UP_R: begin
                        special_nxt = BLOCKING;
                        blocking_state_nxt = LEFT_D;
                        block_xpos_nxt = block_xpos - 2;
                        block_ypos_nxt = block_ypos - 1;
                        blocking_nxt[3] = blocking[3];
                        if(player_ypos % 40 == 0)
                            blocking_nxt[2] = (blocking_in || blocking[2]);
                        else
                            blocking_nxt[2] = 0;
                            
                        blocking_nxt[1] = blocking[1];
                        blocking_nxt[0] = blocking[0];
                    end
                    LEFT_D: begin
                        special_nxt = BLOCKING;
                        if(player_ypos % 40 == 0) begin
                            blocking_state_nxt = RIGHT_D;
                            block_xpos_nxt = block_xpos + 2;
                            block_ypos_nxt = block_ypos;
                        end
                        else begin
                            blocking_state_nxt = LEFT_U;
                            block_xpos_nxt = block_xpos;
                            block_ypos_nxt = block_ypos + 1;
                        end
                        
                        blocking_nxt[3] = blocking[3];
                        blocking_nxt[2] = blocking[2];
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            blocking_nxt[1] = blocking_in;
                        else
                            blocking_nxt[1] = 0;
                        blocking_nxt[0] = blocking[0];
                    end
                    LEFT_U: begin
                        special_nxt = BLOCKING;
                        blocking_state_nxt = RIGHT_D;
                        block_xpos_nxt = block_xpos + 2;
                        block_ypos_nxt = block_ypos - 1;
                        blocking_nxt[3] = blocking[3];
                        blocking_nxt[2] = blocking[2];
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            blocking_nxt[1] = (blocking_in || blocking[1]);
                        else
                            blocking_nxt[1] = 0;
                        blocking_nxt[0] = blocking[0];
                    end
                    RIGHT_D: begin
                        if(player_ypos % 40 == 0) begin
                            blocking_state_nxt = PREPARE;
                            special_nxt = SPECIAL;
                            block_xpos_nxt = 0;
                            block_ypos_nxt = 0;
                        end
                        else begin
                            special_nxt = BLOCKING;
                            blocking_state_nxt = RIGHT_U;
                            block_xpos_nxt = block_xpos;
                            block_ypos_nxt = block_ypos + 1;
                        end
                        blocking_nxt[3] = blocking[3];
                        blocking_nxt[2] = blocking[2];
                        blocking_nxt[1] = blocking[1];
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            blocking_nxt[0] = blocking_in;
                        else
                            blocking_nxt[0] = 0;
                    end
                    RIGHT_U: begin
                        special_nxt = SPECIAL;
                        blocking_state_nxt = PREPARE;
                        block_xpos_nxt = 0;
                        block_ypos_nxt = 0;
                        blocking_nxt[3] = blocking[3];
                        blocking_nxt[2] = blocking[2];
                        blocking_nxt[1] = blocking[1];
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            blocking_nxt[0] = (blocking_in || blocking[0]);
                        else
                            blocking_nxt[0] = 0;
                    end
                    default: begin
                        blocking_state_nxt = PREPARE;
                        block_xpos_nxt = 0;
                        block_ypos_nxt = 0;
                        blocking_nxt = blocking;
                        special_nxt = BLOCKING;
                    end
                endcase
            end
            SPECIAL: begin
                left_right_block = 0;
                position_changed_nxt = position_changed;
                up_direction = 0;
                writing_phase_nxt = 2'b00;
                block_we = 0;
                old_block_nxt = 0;
                write_block_nxt = 0;
                case(blocking_state)
                    PREPARE: begin
                        blocking_state_nxt = START;
                        block_xpos_nxt = plane_xpos + (player_xpos + plane_xpos_ofs)/40;
                        block_ypos_nxt = player_ypos/40;
                        blocking_nxt = blocking;
                        special_nxt = SPECIAL;
                        modi_block_nxt = 0;
                    end
                    START: begin
                        blocking_state_nxt = DOWN_L;
                        block_xpos_nxt = block_xpos;
                        block_ypos_nxt = block_ypos - 1;
                        blocking_nxt = blocking;
                        special_nxt = SPECIAL;
                        modi_block_nxt = 0;
                    end
                    DOWN_L: begin            
                        special_nxt = SPECIAL;
                        blocking_nxt = blocking;
                        if((player_xpos + plane_xpos_ofs)%40 == 0) begin 
                            blocking_state_nxt = UP_L;
                            block_xpos_nxt = block_xpos;
                            block_ypos_nxt = block_ypos + 2;
                        end
                        else begin
                            block_xpos_nxt = block_xpos + 1;
                            blocking_state_nxt = DOWN_R;
                            block_ypos_nxt = block_ypos;
                        end
                        if(player_ypos % 40 == 0)
                            modi_block_nxt[47:42] = block_in;
                        else
                            modi_block_nxt[47:42] = 0;
                            
                        modi_block_nxt[41:0] = 0;
                    end
                    DOWN_R: begin            
                        special_nxt = SPECIAL;
                        blocking_nxt = blocking;
                        blocking_state_nxt = UP_L;
                        block_xpos_nxt = block_xpos - 1;
                        block_ypos_nxt = block_ypos + 2;
                        if(player_ypos % 40 == 0)
                            modi_block_nxt[41:36] = block_in;
                        else
                            modi_block_nxt[41:36] = 0;
                            
                        modi_block_nxt[47:42] = modi_block[47:42];
                        modi_block_nxt[35:0]  = 0;
                    end
                    UP_L: begin
                        special_nxt = SPECIAL;
                        blocking_nxt = blocking;
                        if((player_xpos + plane_xpos_ofs)%40 == 0) begin
                            blocking_state_nxt = LEFT_D;
                            block_xpos_nxt = block_xpos - 1;
                            block_ypos_nxt = block_ypos - 1;
                        end
                        else begin
                            block_xpos_nxt = block_xpos + 1;
                            blocking_state_nxt = UP_R;
                            block_ypos_nxt = block_ypos;
                        end
                        
                        if(player_ypos % 40 == 0)
                            modi_block_nxt[35:30] = block_in;
                        else
                            modi_block_nxt[35:30] = 0;
                            
                        modi_block_nxt[47:36] = modi_block[47:36];
                        modi_block_nxt[29:0]  = 0;
                    end
                    UP_R: begin
                        special_nxt = SPECIAL;
                        blocking_nxt = blocking;
                        blocking_state_nxt = LEFT_D;
                        block_xpos_nxt = block_xpos - 2;
                        block_ypos_nxt = block_ypos - 1;
                        if(player_ypos % 40 == 0)
                            modi_block_nxt[29:24] = block_in;
                        else
                            modi_block_nxt[29:24] = 0;
                            
                        modi_block_nxt[47:30] = modi_block[47:30];
                        modi_block_nxt[23:0]  = 0;
                    end
                    LEFT_D: begin
                        special_nxt = SPECIAL;
                        blocking_nxt = blocking;
                        if(player_ypos % 40 == 0) begin
                            blocking_state_nxt = RIGHT_D;
                            block_xpos_nxt = block_xpos + 2;
                            block_ypos_nxt = block_ypos;
                        end
                        else begin
                            blocking_state_nxt = LEFT_U;
                            block_xpos_nxt = block_xpos;
                            block_ypos_nxt = block_ypos + 1;
                        end
                       
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            modi_block_nxt[23:18] = block_in;
                        else
                            modi_block_nxt[23:18] = 0;
                        modi_block_nxt[47:24] = modi_block[47:24];
                        modi_block_nxt[17:0]  = 0;
                    end
                    LEFT_U: begin
                        special_nxt = SPECIAL;
                        blocking_nxt = blocking;
                        blocking_state_nxt = RIGHT_D;
                        block_xpos_nxt = block_xpos + 2;
                        block_ypos_nxt = block_ypos - 1;
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            modi_block_nxt[17:12] = block_in;
                        else
                            modi_block_nxt[17:12] = 0;
                            
                        modi_block_nxt[47:18] = modi_block[47:18];
                        modi_block_nxt[11:0]  = 0;
                    end
                    RIGHT_D: begin
                        blocking_nxt = blocking;
                        if(player_ypos % 40 == 0) begin
                            blocking_state_nxt = PREPARE;
                            special_nxt = MOD_BLOCK;
                            block_xpos_nxt = 0;
                            block_ypos_nxt = 0;
                        end
                        else begin
                            special_nxt = SPECIAL;
                            blocking_state_nxt = RIGHT_U;
                            block_xpos_nxt = block_xpos;
                            block_ypos_nxt = block_ypos + 1;
                        end
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            modi_block_nxt[11:6] = block_in;
                        else
                            modi_block_nxt[11:6] = 0;
                            
                        modi_block_nxt[47:12] = modi_block[47:12];
                        modi_block_nxt[5:0]  = 0;
                    end
                    RIGHT_U: begin
                        blocking_nxt = blocking;
                        blocking_state_nxt = PREPARE;
                        special_nxt = MOD_BLOCK;
                        block_xpos_nxt = 0;
                        block_ypos_nxt = 0;
                        if((player_xpos + plane_xpos_ofs) % 40 == 0)
                            modi_block_nxt[5:0] = block_in;
                        else
                            modi_block_nxt[5:0] = block_in;
                            
                        modi_block_nxt[47:6] = modi_block[47:6];
                    end
                    default: begin
                        special_nxt = BLOCKING;
                        blocking_state_nxt = PREPARE;
                        block_xpos_nxt = 0;
                        block_ypos_nxt = 0;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                    end
                endcase  
            end
            MOD_BLOCK: begin
                case(blocking_state)
                    PREPARE: begin
                        left_right_block = 0;
                        position_changed_nxt = position_changed;
                        up_direction = 0;
                        blocking_state_nxt = START;
                        block_xpos_nxt = plane_xpos + (player_xpos + plane_xpos_ofs)/40;
                        block_ypos_nxt = player_ypos/40;
                        blocking_nxt = blocking;
                        special_nxt = MOD_BLOCK;
                        modi_block_nxt = modi_block;
                        writing_phase_nxt = 2'b00;
                        old_block_nxt = 0;
                        block_we = 0;
                        write_block_nxt = 0;
                    end
                    START: begin
                        left_right_block = 0;    
                        position_changed_nxt = position_changed;
                        up_direction = 0;
                        blocking_state_nxt = DOWN_L;
                        block_xpos_nxt = block_xpos;
                        block_ypos_nxt = block_ypos - 1;
                        blocking_nxt = blocking;
                        special_nxt = MOD_BLOCK;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        old_block_nxt = modi_block[47:42];
                        writing_phase_nxt = 2'b00;
                        block_we = 0;
                    end
                    DOWN_L: begin   
                        left_right_block = 0;
                        position_changed_nxt = position_changed; 
                        up_direction = 0;    
                        special_nxt = MOD_BLOCK;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[47:42];
                            end
                            2'b01: begin
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[47:42];
                            end
                            2'b11: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos + 1;
                                blocking_state_nxt = DOWN_R;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[41:36];
                            end
                            default: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    DOWN_R: begin   
                        left_right_block = 1;
                        position_changed_nxt = position_changed;
                        up_direction = 0;         
                        special_nxt = MOD_BLOCK;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[41:36];
                            end
                            2'b01: begin
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[41:36];
                            end
                            2'b11: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos - 1;
                                blocking_state_nxt = UP_L;
                                block_ypos_nxt = block_ypos + 2;
                                old_block_nxt = modi_block[35:30];
                            end
                            default: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    UP_L: begin
                        left_right_block = 0;
                        position_changed_nxt = position_changed;
                        up_direction = 1;
                        special_nxt = MOD_BLOCK;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[35:30];
                            end
                            2'b01: begin
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[35:30];
                            end
                            2'b11: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos + 1;
                                blocking_state_nxt = UP_R;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[29:24];
                            end
                            default: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    UP_R: begin
                        left_right_block = 1;
                        position_changed_nxt = position_changed;
                        up_direction = 1;
                        special_nxt = MOD_BLOCK;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[29:24];
                            end
                            2'b01: begin
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[29:24];
                            end
                            2'b11: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos - 2;
                                blocking_state_nxt = LEFT_D;
                                block_ypos_nxt = block_ypos - 1;
                                old_block_nxt = modi_block[23:18];
                            end
                            default: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    LEFT_D: begin   
                        left_right_block = 0;
                        position_changed_nxt = position_changed; 
                        up_direction = 0;    
                        special_nxt = MOD_BLOCK;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[23:18];
                            end
                            2'b01: begin
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[23:18];
                            end
                            2'b11: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = LEFT_U;
                                block_ypos_nxt = block_ypos + 1;
                                old_block_nxt = modi_block[17:12];
                            end
                            default: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    LEFT_U: begin   
                        left_right_block = 0;
                        position_changed_nxt = position_changed;
                        up_direction = 0;         
                        special_nxt = MOD_BLOCK;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[17:12];
                            end
                            2'b01: begin
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[17:12];
                            end
                            2'b11: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos + 2;
                                blocking_state_nxt = RIGHT_D;
                                block_ypos_nxt = block_ypos - 1;
                                old_block_nxt = modi_block[11:6];
                            end
                            default: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    RIGHT_D: begin
                        left_right_block = 1;
                        position_changed_nxt = position_changed;
                        up_direction = 0;
                        special_nxt = MOD_BLOCK;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[11:6];
                            end
                            2'b01: begin
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[11:6];
                            end
                            2'b11: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = RIGHT_U;
                                block_ypos_nxt = block_ypos + 1;
                                old_block_nxt = modi_block[5:0];
                            end
                            default: begin
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    RIGHT_U: begin
                        left_right_block = 1;
                        position_changed_nxt = 0;
                        up_direction = 0;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        write_block_nxt = new_block;
                        case(writing_phase)
                            2'b00: begin
                                special_nxt = MOD_BLOCK;
                                writing_phase_nxt = 2'b01;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[5:0];
                            end
                            2'b01: begin
                                special_nxt = MOD_BLOCK;
                                writing_phase_nxt = 2'b11;
                                block_we = new_block_we;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = blocking_state;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = modi_block[5:0];
                            end
                            2'b11: begin
                                special_nxt = BLOCKING;
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = block_xpos;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = block_ypos;
                                old_block_nxt = old_block;
                            end
                            default: begin
                                special_nxt = BLOCKING;
                                writing_phase_nxt = 2'b00;
                                block_we = 0;
                                block_xpos_nxt = 0;
                                blocking_state_nxt = PREPARE;
                                block_ypos_nxt = 0;
                                old_block_nxt = 0;
                            end
                        endcase
                    end
                    default: begin
                        left_right_block = 0;
                        position_changed_nxt = 0;
                        up_direction = 0;
                        write_block_nxt = 0;
                        special_nxt = BLOCKING;
                        blocking_state_nxt = PREPARE;
                        block_xpos_nxt = 0;
                        block_ypos_nxt = 0;
                        blocking_nxt = blocking;
                        modi_block_nxt = modi_block;
                        writing_phase_nxt = 2'b00;
                        old_block_nxt = 0;
                        block_we = 0;
                    end
                endcase
            end
            default: begin
                left_right_block = 0;
                position_changed_nxt = 0;
                up_direction = 0;
                write_block_nxt = 0;
                block_we = 0;
                modi_block_nxt = modi_block;
                special_nxt = BLOCKING;
                blocking_state_nxt = PREPARE;
                block_xpos_nxt = 0;
                block_ypos_nxt = 0;
                blocking_nxt = blocking;
                writing_phase_nxt = 2'b00;
                old_block_nxt = 0;
            end
        endcase
        end
        else begin
            if(position_changed1)
                position_changed_nxt = 1;
            else
                position_changed_nxt = 0;
            
            left_right_block = 0;
            up_direction = 0;
            write_block_nxt = 0;
            block_we = 0;
            modi_block_nxt = modi_block;
            special_nxt = BLOCKING;
            blocking_state_nxt = PREPARE;
            block_xpos_nxt = 0;
            block_ypos_nxt = 0;
            blocking_nxt = blocking;
            writing_phase_nxt = 2'b00;
            old_block_nxt = 0;
        end
    end

    //*************************************
    // End of logic for blocking the player
    //*************************************
 
    //Breaking the locks and getting points
    wire [5:0] new_block;
    reg [5:0] old_block, old_block_nxt;
    reg up_direction, left_right_block;
    
    new_block new_block_u(
        .block_in(old_block),
        .up_direction(up_direction),
        .direction(left_right_block),
        .block_out(new_block),
        .relative_xpos(player_xpos + plane_xpos_ofs),
        .relative_ypos(player_ypos),
        .write_enable(new_block_we),
        .new_point(new_point)
    );

endmodule
