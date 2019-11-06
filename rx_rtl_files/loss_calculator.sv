module loss_calculator #(parameter maxaux = 16'h0fff, parameter maxaux_bits = 'd12) (
    input wire clk,
    (* mark_debug = "true" *) input wire rst,
    (* mark_debug = "true" *) input wire [15:0] segment_number_max,
    (* mark_debug = "true" *) input wire [15:0] segment_number,
    (* mark_debug = "true" *) input wire valid_in,
    (* mark_debug = "true" *) input wire [maxaux_bits :0] aux,
    (* mark_debug = "true" *) output reg [15:0] ok,
    (* mark_debug = "true" *) output reg [15:0] ng,
    (* mark_debug = "true" *) output reg [15:0] lostnum, //important
    (* mark_debug = "true" *) output reg [15:0] count,
    (* mark_debug = "true" *) output reg done
);

    (* mark_debug = "true" *) enum reg[2:0] {INIT,WAITING,RUNNING,CALCULATING,ENDED} state=INIT;
    (* mark_debug = "true" *) reg wea,dina;
    (* mark_debug = "true" *) wire [15:0] addra;
    (* mark_debug = "true" *) wire douta;
    bram_1b65536w bram_1b65536w_this (
        .clka(clk),
        .wea(wea),
        .addra(addra),
        .dina(dina),
        .douta(douta)
        );
    //reg array[maxaux:0];
    reg [maxaux_bits:0] ar_index; assign addra = (state==RUNNING) ? aux : ar_index;
    wire [maxaux_bits:0] ar_index_next = (ar_index==maxaux) ? ar_index : ar_index + 1'b1;
    
    //(* mark_debug = "true" *) wire seg_en = segment_number[0];
    (* mark_debug = "true" *) reg seg_en = 0;
    //wire seg_en = !segment_number[0];
    (* mark_debug = "true" *) reg valid_in_inter;
    reg seg_en_inter;
    (* mark_debug = "true" *) reg seg_en__inter;
    reg [1:0] seg_en_inter_sr;
    
    (* mark_debug = "true" *) wire segmax = (segment_number + 1'b1 == segment_number_max);

    always @(posedge clk) begin
        if (rst) begin
            ok='d0;ng='d0;lostnum='d0;state=INIT;
            ar_index = 'd0; count='d0;done=1'b0;
            seg_en = 'b0;valid_in_inter=1'b0;seg_en_inter=1'b0;
            seg_en__inter='b0;seg_en_inter_sr='b0;
        end
        else begin
            seg_en_inter_sr = {seg_en_inter_sr[0],seg_en_inter};
            seg_en__inter <= seg_en__inter + seg_en_inter;
            valid_in_inter <= valid_in;
            seg_en_inter <= seg_en;
            if (valid_in && segmax) begin
                seg_en = !seg_en;
            end
            
            case (state)
                INIT: 
                begin
                    dina = 1'b0;
                    //if (valid_in) begin
                        if (ar_index == maxaux) begin
                            ar_index <= 'd0;
                            state = WAITING;
                        end
                        else begin
                            //array[ar_index] <= 1'b0;
                            wea = 1'b1;
                           
                            ar_index <= ar_index_next;
                        end
                    //end
                end
                WAITING: // waiting for zero
                begin
                    dina = 1'b1;
                    if (valid_in_inter && /*seg_en_inter &&*/ aux[maxaux_bits:0]=='d0) begin
                        state = RUNNING;
                        //array[0] = 1'b1;
                        wea = 1'b1;
                    end
                end
                RUNNING:
                begin
                    wea = 1'b1;
                    dina = 1'b1;
                   // if (valid_in_inter) begin
                        if (valid_in_inter && /*!seg_en_inter && */aux[maxaux_bits]==1'b1) begin
                            state <= CALCULATING;
                            ar_index <= 'd0;
                           
                        end
                        //wea <= seg_en_inter;
//                        if (seg_en) begin
//                            wea <= seg_en;
//                            array[aux] <= 1'b1;
                            
//                        end
                    //end
                end
                CALCULATING:
                begin
                    dina = 1'b0;
                    wea = 1'b0;
                    ar_index <= ar_index_next;
                    if (ar_index == maxaux) begin
                        state <= ENDED;
                    end 

                    //if (array[ar_index]==1'b1) begin
                    if (douta==1'b1) begin
                        ok <= ok + 1'b1;
                        count <= count + 1'b1;
                    end
                    else begin
                        ng <= ng + 1'b1;
                        lostnum <= lostnum + 1'b1;
                        count <= count + 1'b1;
                    end
                end
                ENDED:
                begin
                    done='b1;
                end
                default:
                    state=INIT;
            endcase
        end
    end



endmodule
