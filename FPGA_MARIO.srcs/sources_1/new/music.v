`timescale 1 ns / 1 ps

module Music (
	input wire     clk,
	output reg     speaker
);

    wire [7:0]  fullnote;
    wire [2:0]  octave;
    wire [3:0]  note;
    reg  [30:0] tone;
    reg  [8:0]  clkdivider;
    reg  [8:0]  counter_note;
    reg  [7:0]  counter_octave;

    music_rom music_rom_u (
        .clk(clk), 
        .address(tone[30:22]), 
        .note(fullnote)
    );
    
    divide_by12 divide_by12_u (
        .numerator(fullnote[5:0]), 
        .quotient(octave), 
        .remainder(note)
    );
    
    always @(posedge clk) 
        tone    <= tone+31'd1;
    
    always @*
    case(note)
         0: clkdivider = 9'd511; //A
         1: clkdivider = 9'd482; // A#/Bb
         2: clkdivider = 9'd455; //B
         3: clkdivider = 9'd430; //C
         4: clkdivider = 9'd405; // C#/Db
         5: clkdivider = 9'd383; //D
         6: clkdivider = 9'd361; // D#/Eb
         7: clkdivider = 9'd341; //E
         8: clkdivider = 9'd322; //F
         9: clkdivider = 9'd303; // F#/Gb
        10: clkdivider = 9'd286; //G
        11: clkdivider = 9'd270; // G#/Ab
        default: clkdivider = 9'd0;
    endcase
    
    
    always @(posedge clk) counter_note <= (counter_note==0 ? clkdivider : counter_note-9'd1);
    always @(posedge clk) if(counter_note==0) counter_octave <= (counter_octave==0 ? 8'd255 >> octave : counter_octave-8'd1);
    always @(posedge clk) if(counter_note==0 && counter_octave==0 && fullnote!=0 && tone[21:18]!=0) speaker <= ~speaker;
    
    endmodule
    
    
    
    
    // This module is resposible for prividing divide by 12 operation.
    module divide_by12(
        input [5:0] numerator,  // value to be divided by 12
        output reg [2:0] quotient, 
        output [3:0] remainder
    );
    
    reg [1:0] remainder3to2;
    always @(numerator[5:2])
    case(numerator[5:2])        // look-up table
         0: begin quotient=0; remainder3to2=0; end
         1: begin quotient=0; remainder3to2=1; end
         2: begin quotient=0; remainder3to2=2; end
         3: begin quotient=1; remainder3to2=0; end
         4: begin quotient=1; remainder3to2=1; end
         5: begin quotient=1; remainder3to2=2; end
         6: begin quotient=2; remainder3to2=0; end
         7: begin quotient=2; remainder3to2=1; end
         8: begin quotient=2; remainder3to2=2; end
         9: begin quotient=3; remainder3to2=0; end
        10: begin quotient=3; remainder3to2=1; end
        11: begin quotient=3; remainder3to2=2; end
        12: begin quotient=4; remainder3to2=0; end
        13: begin quotient=4; remainder3to2=1; end
        14: begin quotient=4; remainder3to2=2; end
        15: begin quotient=5; remainder3to2=0; end
    endcase
    
    assign remainder[1:0] = numerator[1:0];  // the first 2 bits are copied through
    assign remainder[3:2] = remainder3to2;  // and the last 2 bits come from the case statement
    
    endmodule
    
    // This module contains ROM for Super Mario Bros Theme notes.
    module music_rom(
        input clk,
        input [8:0] address,
        output reg [7:0] note
    );
    
    always @(posedge clk)
        case(address)
            // 1st tact
            0: note<= 8'd34;
            1: note<= 8'd34;
            2: note<= 8'd00;
            3: note<= 8'd34;
            4: note<= 8'd00;
            5: note<= 8'd30;
            6: note<= 8'd34;
            7: note<= 8'd34;
            // 2nd tact
            8: note<= 8'd37;
            9: note<= 8'd37;
            10: note<= 8'd00;
            11: note<= 8'd00;
            12: note<= 8'd25;
            13: note<= 8'd25;
            14: note<= 8'd00;
            15: note<= 8'd00;
            // 3rd tact
            16: note<= 8'd30;
            17: note<= 8'd30;
            18: note<= 8'd00;
            19: note<= 8'd25;
            20: note<= 8'd25;
            21: note<= 8'd00;
            22: note<= 8'd22;
            23: note<= 8'd22;
            // 4th tact
            24: note<= 8'd00;
            25: note<= 8'd27;
            26: note<= 8'd27;
            27: note<= 8'd29;
            28: note<= 8'd29;
            29: note<= 8'd28;
            30: note<= 8'd27;
            31: note<= 8'd27;
            // 5th tact
            32: note<= 8'd25;
            33: note<= 8'd25;
            34: note<= 8'd34;
            35: note<= 8'd37;
            36: note<= 8'd39;
            37: note<= 8'd39;
            38: note<= 8'd35;
            39: note<= 8'd37;
            // 6th tact
            40: note<= 8'd00;
            41: note<= 8'd34;
            42: note<= 8'd34;
            43: note<= 8'd30;
            44: note<= 8'd32;
            45: note<= 8'd29;
            46: note<= 8'd29;
            47: note<= 8'd00;
            // 7th tact
            48: note<= 8'd00;
            49: note<= 8'd00;
            50: note<= 8'd37;
            51: note<= 8'd36;
            52: note<= 8'd37;
            53: note<= 8'd33;
            54: note<= 8'd33;
            55: note<= 8'd34;
            // 8th tact
            56: note<= 8'd00;
            57: note<= 8'd26;
            58: note<= 8'd27;
            59: note<= 8'd30;
            60: note<= 8'd00;
            61: note<= 8'd27;
            62: note<= 8'd30;
            63: note<= 8'd32;
            // 9th tact
            64: note<= 8'd00;
            65: note<= 8'd00;
            66: note<= 8'd37;
            67: note<= 8'd36;
            68: note<= 8'd37;
            69: note<= 8'd33;
            70: note<= 8'd33;
            71: note<= 8'd34;
            // 10th tact
            72: note<= 8'd00;
            73: note<= 8'd42;
            74: note<= 8'd42;
            75: note<= 8'd42;
            76: note<= 8'd42;
            77: note<= 8'd42;
            78: note<= 8'd00;
            79: note<= 8'd00;
            // 11th tact
            80: note<= 8'd0;
            81: note<= 8'd0;
            82: note<= 8'd37;
            83: note<= 8'd36;
            84: note<= 8'd37;
            85: note<= 8'd33;
            86: note<= 8'd33;
            87: note<= 8'd34;
            // 12th tact
            88: note<= 8'd0;
            89: note<= 8'd26;
            90: note<= 8'd27;
            91: note<= 8'd30;
            92: note<= 8'd0;
            93: note<= 8'd27;
            94: note<= 8'd30;
            95: note<= 8'd32;
            // 13th tact
            96: note<= 8'd0;
            97: note<= 8'd0;
            98: note<= 8'd33;
            99: note<= 8'd33;
            100: note<= 8'd0;
            101: note<= 8'd32;
            102: note<= 8'd32;
            103: note<= 8'd0;
            // 14th tact
            104: note<= 8'd30;
            105: note<= 8'd30;
            106: note<= 8'd0;
            107: note<= 8'd0;
            108: note<= 8'd0;
            109: note<= 8'd0;
            110: note<= 8'd0;
            111: note<= 8'd0;
            // 15th tact
            112: note<= 8'd30;
            113: note<= 8'd30;
            114: note<= 8'd0;
            115: note<= 8'd30;
            116: note<= 8'd0;
            117: note<= 8'd30;
            118: note<= 8'd32;
            119: note<= 8'd32;
            // 16th tact
            120: note<= 8'd34;
            121: note<= 8'd30;
            122: note<= 8'd0;
            123: note<= 8'd27;
            124: note<= 8'd25;
            125: note<= 8'd25;
            126: note<= 8'd25;
            127: note<= 8'd25;
            // 17th tact
            128: note<= 8'd30;
            129: note<= 8'd30;
            130: note<= 8'd0;
            131: note<= 8'd30;
            132: note<= 8'd0;
            133: note<= 8'd30;
            134: note<= 8'd32;
            135: note<= 8'd24;
            // 18th tact
            136: note<= 8'd0;
            137: note<= 8'd0;
            138: note<= 8'd0;
            139: note<= 8'd0;
            140: note<= 8'd0;
            141: note<= 8'd0;
            142: note<= 8'd0;
            143: note<= 8'd0;
            // 19th tact
            144: note<= 8'd30;
            145: note<= 8'd30;
            146: note<= 8'd0;
            147: note<= 8'd30;
            148: note<= 8'd0;
            149: note<= 8'd30;
            150: note<= 8'd32;
            151: note<= 8'd32;
            // 20th tact
            152: note<= 8'd34;
            153: note<= 8'd30;
            154: note<= 8'd0;
            155: note<= 8'd27;
            156: note<= 8'd25;
            157: note<= 8'd25;
            158: note<= 8'd25;
            159: note<= 8'd25;
            // 21st tact
            160: note<= 8'd34;
            161: note<= 8'd34;
            162: note<= 8'd0;
            163: note<= 8'd34;
            164: note<= 8'd0;
            165: note<= 8'd30;
            166: note<= 8'd34;
            167: note<= 8'd34;
            // 22nd tact
            168: note<= 8'd37;
            169: note<= 8'd37;
            170: note<= 8'd0;
            171: note<= 8'd0;
            172: note<= 8'd25;
            173: note<= 8'd25;
            174: note<= 8'd0;
            175: note<= 8'd0;
            // 23rd tact
            176: note<= 8'd30;
            177: note<= 8'd30;
            178: note<= 8'd0;
            179: note<= 8'd25;
            180: note<= 8'd25;
            181: note<= 8'd0;
            182: note<= 8'd22;
            183: note<= 8'd22;
            // 24th tact
            184: note<= 8'd0;
            185: note<= 8'd27;
            186: note<= 8'd27;
            187: note<= 8'd29;
            188: note<= 8'd29;
            189: note<= 8'd28;
            190: note<= 8'd27;
            191: note<= 8'd27;
            // 25th tact
            192: note<= 8'd25;
            193: note<= 8'd25;
            194: note<= 8'd34;
            195: note<= 8'd37;
            196: note<= 8'd39;
            197: note<= 8'd39;
            198: note<= 8'd35;
            199: note<= 8'd37;
            // 26th tact
            200: note<= 8'd0;
            201: note<= 8'd34;
            202: note<= 8'd34;
            203: note<= 8'd30;
            204: note<= 8'd32;
            205: note<= 8'd29;
            206: note<= 8'd29;
            207: note<= 8'd0;
            // 27th tact
            208: note<= 8'd34;
            209: note<= 8'd30;
            210: note<= 8'd30;
            211: note<= 8'd25;
            212: note<= 8'd0;
            213: note<= 8'd0;
            214: note<= 8'd26;
            215: note<= 8'd26;
            // 28th tact
            216: note<= 8'd27;
            217: note<= 8'd35;
            218: note<= 8'd35;
            219: note<= 8'd35;
            220: note<= 8'd27;
            221: note<= 8'd27;
            222: note<= 8'd0;
            223: note<= 8'd0;
            // 29th tact
            224: note<= 8'd29;
            225: note<= 8'd29;
            226: note<= 8'd39;
            227: note<= 8'd39;
            228: note<= 8'd39;
            229: note<= 8'd37;
            230: note<= 8'd35;
            231: note<= 8'd35;
            // 30th tact
            232: note<= 8'd34;
            233: note<= 8'd30;
            234: note<= 8'd30;
            235: note<= 8'd27;
            236: note<= 8'd25;
            237: note<= 8'd25;
            238: note<= 8'd0;
            239: note<= 8'd0;
            // 31st tact
            240: note<= 8'd34;
            241: note<= 8'd34;
            242: note<= 8'd30;
            243: note<= 8'd30;
            244: note<= 8'd25;
            245: note<= 8'd0;
            246: note<= 8'd26;
            247: note<= 8'd26;
            // 32nd tact
            248: note<= 8'd27;
            249: note<= 8'd35;
            250: note<= 8'd35;
            251: note<= 8'd35;
            252: note<= 8'd27;
            253: note<= 8'd27;
            254: note<= 8'd0;
            255: note<= 8'd0;
            // 33rd tact
            256: note<= 8'd29;
            257: note<= 8'd35;
            258: note<= 8'd35;
            259: note<= 8'd35;
            260: note<= 8'd35;
            261: note<= 8'd35;
            262: note<= 8'd34;
            263: note<= 8'd32;
            // 34th tact
            264: note<= 8'd30;
            265: note<= 8'd30;
            266: note<= 8'd30;
            267: note<= 8'd30;
            268: note<= 8'd0;
            269: note<= 8'd0;
            270: note<= 8'd0;
            271: note<= 8'd0;
            // 35th tact
            272: note<= 8'd30;
            273: note<= 8'd30;
            274: note<= 8'd0;
            275: note<= 8'd30;
            276: note<= 8'd0;
            277: note<= 8'd30;
            278: note<= 8'd32;
            279: note<= 8'd32;
            // 36th tact
            280: note<= 8'd34;
            281: note<= 8'd30;
            282: note<= 8'd0;
            283: note<= 8'd27;
            284: note<= 8'd25;
            285: note<= 8'd25;
            286: note<= 8'd25;
            287: note<= 8'd25;
            // 37th tact
            288: note<= 8'd30;
            289: note<= 8'd30;
            290: note<= 8'd0;
            291: note<= 8'd30;
            292: note<= 8'd0;
            293: note<= 8'd30;
            294: note<= 8'd32;
            295: note<= 8'd34;
            // 38th tact
            296: note<= 8'd0;
            297: note<= 8'd0;
            298: note<= 8'd34;
            299: note<= 8'd37;
            300: note<= 8'd46;
            301: note<= 8'd42;
            302: note<= 8'd44;
            303: note<= 8'd49;
            // 39th tact
            304: note<= 8'd30;
            305: note<= 8'd30;
            306: note<= 8'd0;
            307: note<= 8'd30;
            308: note<= 8'd0;
            309: note<= 8'd30;
            310: note<= 8'd32;
            311: note<= 8'd32;
            // 40th tact
            312: note<= 8'd34;
            313: note<= 8'd30;
            314: note<= 8'd0;
            315: note<= 8'd27;
            316: note<= 8'd25;
            317: note<= 8'd25;
            318: note<= 8'd25;
            319: note<= 8'd25;
            // 41st tact
            320: note<= 8'd34;
            321: note<= 8'd34;
            322: note<= 8'd0;
            323: note<= 8'd34;
            324: note<= 8'd0;
            325: note<= 8'd30;
            326: note<= 8'd34;
            327: note<= 8'd34;
            // 42nd tact
            328: note<= 8'd37;
            329: note<= 8'd37;
            330: note<= 8'd0;
            331: note<= 8'd0;
            332: note<= 8'd25;
            333: note<= 8'd25;
            334: note<= 8'd0;
            335: note<= 8'd0;
            // 43rd tact
            336: note<= 8'd34;
            337: note<= 8'd30;
            338: note<= 8'd30;
            339: note<= 8'd25;
            340: note<= 8'd0;
            341: note<= 8'd0;
            342: note<= 8'd26;
            343: note<= 8'd26;
            // 44th tact
            344: note<= 8'd27;
            345: note<= 8'd35;
            346: note<= 8'd35;
            347: note<= 8'd35;
            348: note<= 8'd27;
            349: note<= 8'd27;
            350: note<= 8'd0;
            351: note<= 8'd0;
            // 45th tact
            352: note<= 8'd29;
            353: note<= 8'd29;
            354: note<= 8'd39;
            355: note<= 8'd39;
            356: note<= 8'd39;
            357: note<= 8'd37;
            358: note<= 8'd35;
            359: note<= 8'd35;
            // 46th tact
            360: note<= 8'd34;
            361: note<= 8'd30;
            362: note<= 8'd30;
            363: note<= 8'd27;
            364: note<= 8'd25;
            365: note<= 8'd25;
            366: note<= 8'd0;
            367: note<= 8'd0;
            // 47th tact
            368: note<= 8'd34;
            369: note<= 8'd30;
            370: note<= 8'd30;
            371: note<= 8'd25;
            372: note<= 8'd0;
            373: note<= 8'd0;
            374: note<= 8'd26;
            375: note<= 8'd26;
            // 48th tact
            376: note<= 8'd27;
            377: note<= 8'd35;
            378: note<= 8'd35;
            379: note<= 8'd35;
            380: note<= 8'd27;
            381: note<= 8'd27;
            382: note<= 8'd0;
            383: note<= 8'd0;
            // 49th tact
            384: note<= 8'd29;
            385: note<= 8'd35;
            386: note<= 8'd35;
            387: note<= 8'd35;
            388: note<= 8'd35;
            389: note<= 8'd34;
            390: note<= 8'd32;
            391: note<= 8'd32;
            // 50th tact
            392: note<= 8'd30;
            393: note<= 8'd30;
            394: note<= 8'd30;
            395: note<= 8'd30;
            396: note<= 8'd0;
            397: note<= 8'd0;
            398: note<= 8'd0;
            399: note<= 8'd0;
            // 51st tact
            400: note<= 8'd30;
            401: note<= 8'd30;
            402: note<= 8'd0;
            403: note<= 8'd25;
            404: note<= 8'd25;
            405: note<= 8'd0;
            406: note<= 8'd22;
            407: note<= 8'd22;
            // 52nd tact
            408: note<= 8'd27;
            409: note<= 8'd27;
            410: note<= 8'd29;
            411: note<= 8'd27;
            412: note<= 8'd26;
            413: note<= 8'd28;
            414: note<= 8'd26;
            415: note<= 8'd26;
            // 53rd tact
            416: note<= 8'd25;
            417: note<= 8'd25;
            418: note<= 8'd25;
            419: note<= 8'd25;
            420: note<= 8'd25;
            421: note<= 8'd25;
            422: note<= 8'd25;
            423: note<= 8'd25;
            // 54th tact
            424: note<= 8'd0;
            425: note<= 8'd0;
            426: note<= 8'd0;
            427: note<= 8'd0;
            428: note<= 8'd0;
            429: note<= 8'd0;
            430: note<= 8'd0;
            431: note<= 8'd0;
            
            default: note <= 8'd0;
        endcase

endmodule
