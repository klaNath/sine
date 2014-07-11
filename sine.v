
module sine (
    phase,
    sine_out
    );  
    
    
    input   wire            [20:0]  phase;
    output  wire            [16:0]  sine_out;
    
    wire    [8:0]   rom_adrs;   
    wire    [9:0]   leap_coeff;
    wire    [15:0]  sin_rom_out;
    wire    [15:0]  diff_rom_out;
    wire    [25:0]  leap_add_p;
    wire    [15:0]  leap_add;
    
    wire    [16:0]  signed_sine;
    
    function [8:0] adrs_conv;    
        input   [8:0]   adrs_p;
        input           sel;
        begin
            case(sel)
            0   :   adrs_conv = adrs_p;
            1   :   adrs_conv = 9'H1FF - adrs_p;
            default : adrs_conv = 9'bxxxxxxxxx;
            endcase
        end
    endfunction
    
    function [9:0] leap_conv;
        input   [9:0]   leap_p;
        input           sel;
        begin
            case(sel)
            0   :   leap_conv = leap_p;
            1   :   leap_conv = 10'H2FF - leap_p;
            default : leap_conv = 10'bxxxxxxxxxx;
            endcase
        end
    endfunction
    
    function [16:0] quad3_4;
        input   [16:0]  signed_sine;
        input           sel;
        begin
            case(sel)
            0   :   quad3_4 = signed_sine >> 1;
            1   :   quad3_4 = ~(signed_sine >> 1) + 1'b1;
            default : quad3_4 = 16'bxxxxxxxxxxxxxxxx;
            endcase
        end
    endfunction
    
    assign  leap_add_p = diff_rom_out * leap_coeff;
    assign  leap_add = leap_add_p[25:9];
    assign  signed_sine = sin_rom_out[15:0] + leap_add[15:0];
        
    assign  rom_adrs = adrs_conv(phase[18:10], phase[19]);
    assign  leap_coeff = leap_conv(phase[9:0], phase[19]);
    assign  sine_out = quad3_4(signed_sine, phase[20]);

     sin_rom sin_rom_i(
        .inadrs(rom_adrs),
        .outsine(sin_rom_out)
        );
        
    diff_rom diff_rom_i(
        .inadrs(rom_adrs),
        .outdiff(diff_rom_out)
        );
    
endmodule
    
    