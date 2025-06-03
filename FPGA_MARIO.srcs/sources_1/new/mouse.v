// fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// Fixed: Mouse button LED indicator logic
module mouse_basys3_FPGA(
    input clock_100Mhz,         // 100 MHz clock source on Basys 3 FPGA
    input reset,                // reset
    input Mouse_Data,           // mouse PS2 data
    input Mouse_Clk,            // Mouse PS2 Clock
    output reg middle_button             // LED[2]: left click, [1]: middle click, [0]: right click
);
    
    reg [3:0] Anode_Activate; // anode signals of the 7-segment LED display
    reg [6:0] LED_out;        // cathode patterns of the 7-segment LED display
    // Mouse data receive state
    reg [7:0] mouse_packet[2:0];    // three bytes per PS/2 mouse packet
    reg [1:0] byte_count;           // which byte of the packet we're on
    reg [3:0] bit_count;            // bit index within a byte
    reg [7:0] shift_reg;            // shift register to collect bits
    
    // Button states
    reg left_click, right_click, middle_click;

    // Display logic
    reg [15:0] displayed_number;
    reg [3:0] LED_BCD;
    reg [20:0] refresh_counter;
    wire [1:0] LED_activating_counter;

    // Refresh counter
    always @(posedge clock_100Mhz or posedge reset) begin
        if (reset)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end

    assign LED_activating_counter = refresh_counter[20:19];

    // Anode activate and BCD extract
    always @(*) begin
        case (LED_activating_counter)
            2'b00: begin
                Anode_Activate = 4'b0111;
                LED_BCD = displayed_number / 1000;
            end
            2'b01: begin
                Anode_Activate = 4'b1011;
                LED_BCD = (displayed_number % 1000) / 100;
            end
            2'b10: begin
                Anode_Activate = 4'b1101;
                LED_BCD = ((displayed_number % 1000) % 100) / 10;
            end
            2'b11: begin
                Anode_Activate = 4'b1110;
                LED_BCD = ((displayed_number % 1000) % 100) % 10;
            end
        endcase
    end

    // 7-segment LED display logic
    always @(*) begin
        case (LED_BCD)
            4'b0000: LED_out = 7'b0000001; // "0"
            4'b0001: LED_out = 7'b1001111; // "1"
            4'b0010: LED_out = 7'b0010010; // "2"
            4'b0011: LED_out = 7'b0000110; // "3"
            4'b0100: LED_out = 7'b1001100; // "4"
            4'b0101: LED_out = 7'b0100100; // "5"
            4'b0110: LED_out = 7'b0100000; // "6"
            4'b0111: LED_out = 7'b0001111; // "7"
            4'b1000: LED_out = 7'b0000000; // "8"
            4'b1001: LED_out = 7'b0000100; // "9"
            default: LED_out = 7'b0000001; // "0"
        endcase
    end

    // Mouse PS/2 receiving logic
    always @(negedge Mouse_Clk or posedge reset) begin
        if (reset) begin
            bit_count <= 0;
            byte_count <= 0;
            shift_reg <= 0;
            left_click <= 0;
            right_click <= 0;
            middle_click <= 0;
        end else begin
            shift_reg <= {Mouse_Data, shift_reg[7:1]};
            bit_count <= bit_count + 1;

            if (bit_count == 10) begin // 1 start bit + 8 data + 1 parity + 1 stop = 11, store on 10
                bit_count <= 0;
                mouse_packet[byte_count] <= shift_reg[7:0];
                
                // 只有当接收完整个3字节数据包后才处理按键状态
                if (byte_count == 2) begin
                    byte_count <= 0;
                    
                    // 从第一个字节提取按键状态（现在存储在mouse_packet[0]中）
                    left_click <= mouse_packet[0][0];    // bit 0: 左键
                    right_click <= mouse_packet[0][1];   // bit 1: 右键  
                    middle_click <= mouse_packet[0][2];  // bit 2: 中键(滚轮)

                    // 计数逻辑：左键增加，右键减少
                    if (mouse_packet[0][0]) // 左键按下
                        displayed_number <= displayed_number + 1;
                    else if (mouse_packet[0][1] && displayed_number > 0) // 右键按下且数字大于0
                        displayed_number <= displayed_number - 1;
                end else begin
                    byte_count <= byte_count + 1;
                end
            end
        end
    end

    // Assign LED outputs
    always @(*) begin
//        LED[2] = left_click;   // LED[2]: 左键状态
        middle_button = middle_click; // LED[1]: 中键(滚轮)状态  
//        LED[0] = right_click;  // LED[0]: 右键状态
    end

endmodule