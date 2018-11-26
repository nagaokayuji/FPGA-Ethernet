 module byte_data(
	input wire clk,
	input wire start,
	input wire advance,
//	input wire [15:0] mydata,
	input wire [7:0] aux, // auxiliary number
	input wire [15:0] segment_num,
	input wire [7:0] index_clone,
	input wire [7:0] vramdata,
	input wire [19:0] startaddr,
	output reg [19:0] vramaddr = 0,
	output reg [1:0] vramaddr_c = 0, // rgb selector. 
	output reg [19:0] lastaddr = 0,
	output reg busy = 1'b0,
	output reg [7:0] data = 8'b0,
	
	output reg data_user = 1'b0,
	output reg data_valid = 1'b0,
	output reg data_enable = 1'b0,
	output reg almost_sent = 1'b0,
	output reg [12:0] count_for_bram = 0,
	output reg [12:0] count_for_bram_b=0,
	output reg count_for_bram_en = 0
	//output reg send_busy = 1'b0
	);
//parameter VGA_ -> 420*240
parameter xmax = 320;
parameter ymax = 180;


parameter ip_header_bytes = 20;
parameter udp_header_bytes = 8;
parameter data_bytes = 1444; // 1444 Bytes. 4: my protocol, 1440: payload.  
parameter ip_total_bytes = ip_header_bytes + udp_header_bytes + data_bytes;//20 + 8 + 1444 = 1472 = x5c0
parameter udp_total_bytes = udp_header_bytes + data_bytes; // 8 + data_bytes = 1452 = x5ac
reg start_internal = 1'b0;
reg [11:0] counter = 12'b0;

// added 7/8
reg [7:0] index_clone_rised;
//reg [15:0] mydata_rised;

// ethernet frame header
reg [47:0] eth_src_mac = 48'hdeadbeef0123;
reg [47:0] eth_dst_mac = 48'hffffffffffff;
reg [15:0] eth_type = 16'h0800;

// ip header
reg [3:0] ip_version = 4'h4;
reg [3:0] ip_header_len = 4'h5;
reg [7:0] ip_dscp_ecn = 8'h00;
reg [15:0] ip_identification = 16'h0000;
reg [15:0] ip_length = ip_total_bytes;
reg [15:0] ip_flags_and_frag = 16'h0000;
reg [7:0] ip_ttl = 8'h10;
reg [7:0] ip_protocol = 8'h11;
wire [15:0] ip_checksum;// = 16'h0000; // calculated later on
reg [31:0] ip_src_addr = 32'hc0a80140; // 192.168.1.64
reg [31:0] ip_dst_addr = 32'hc0a80102; // 192.168.1.2

// for calculating the checksum
wire [31:0] ip_checksum1;// = 32'h0;
wire [15:0] ip_checksum2;// = 16'h0;

// UDP header
reg [15:0] udp_src_port = 16'h1000; // port 4096
reg [15:0] udp_dst_port = 16'h1000; // port 4096
reg [15:0] udp_length = udp_total_bytes; // ok?
reg [15:0] udp_checksum = 16'h0000;

//wire[3:0] data_from_vram;


//begin
//calculate tcp checksum
// this should all collapse down to a constant at build-time
	 //--- Step 1) 4500 + 0030 + 4422 + 4000 + 8006 + 0000 + (0410 + 8A0C + FFFF + FFFF) = 0002BBCF (32-bit sum)
//always @* begin
assign ip_checksum1 = 32'd0 + {ip_version, ip_header_len, ip_dscp_ecn} + ip_identification
				+ ip_length + ip_flags_and_frag + {ip_ttl, ip_protocol}
				+ ip_src_addr[31:16] + ip_src_addr[15:0] + ip_dst_addr[31:16]
				+ ip_dst_addr[15:0];

	 //-- Step 2) 0002 + BBCF = BBD1 = 1011101111010001 (1's complement 16-bit sum, formed by "end around carry" of 32-bit 2's complement sum)
assign ip_checksum2 = ip_checksum1[31:16] + ip_checksum1[15:0];
	 //-- Step 3) ~BBD1 = 0100010000101110 = 442E (1's complement of 1's complement 16-bit sum)
assign ip_checksum  = ~ip_checksum2;
reg flag_max = 0;
// 43( == 0x2b),wrong data
always @(posedge clk) begin
//if (counter >= 41 && counter <= 1123) begin
/*
43==0x2b
42==0x2a
41==0x29

addr: 0x24,0x25,0x26==36,37,38
count=2b == 43のとき，addr=startaddrのデータが必要
*/
if (counter == 35) begin flag_max = 0; vramaddr <= startaddr; count_for_bram_b <= 0; count_for_bram <= 0;end
if (counter >= 41 && counter <= 1122) begin// 43?
		if (flag_max || (vramaddr > 57600/*xmax * ymax * 3*/))	begin
		  vramaddr <= 0;
		  flag_max <= 1;
		  vramaddr_c <= 0;
		  count_for_bram_b <= 0;
		end
		else begin 
		if (count_for_bram_b < 1080)
		  count_for_bram_b <= count_for_bram_b + 1;
		if (vramaddr_c == 2) begin
		  vramaddr_c <= 0;
		  vramaddr <= vramaddr + 1;
		end
		else begin
		vramaddr_c <= vramaddr_c + 1;
		end
		end
	
	if (counter == 12'd40) count_for_bram <= 0;
	if (counter >= 12'd42 && counter <= 12'd1122 && count_for_bram < 1080)  begin
	       count_for_bram_en <= 1;
	       if (counter >= 12'd43)
	           count_for_bram <= count_for_bram + 1;
	      
	 end
	 else count_for_bram_en <= 0;
end
end


always @(posedge clk) begin
	// update the counter
	if (start == 1'b1) begin
		start_internal <= 1'b1;
		busy <= 1'b1;
	end

	data_enable <= 1'b0;

	if (advance == 1'b1) begin
		data_enable <= 1'b1;
		if (counter == 1'b0)begin
		//	if ((start_internal == 1'b1) || (start == 1'b1)) begin
			if (start == 1'b1) begin
				busy <= 1'b1;
				counter <= counter + 1'b1;
				start_internal <= start;
			end
			else begin 
				busy <= 1'b0;
						end
		end
		else begin
			counter <= counter + 1'b1;
		end
	end

	// note, this uses the current value of counter, not the one assigned above!!!
	data <= 8'b00000000;
	case (counter)
		// pause at 0count when idle
		12'h0:  begin// must be NULL???????
						//mydata_rised <= mydata;
						
						//index_clone_rised <= index_clone;
				end
		12'h1: begin
				//busy <= 1'b1;
				almost_sent <= 1'b0;
						data <= eth_dst_mac[47:40];
						data_valid <= 1'b1;
						end

		// ethernet destination
		12'h2: data <= eth_dst_mac[39:32];
		12'h3: data <= eth_dst_mac[31:24];
		12'h4: data <= eth_dst_mac[23:16];
		12'h5: data <= eth_dst_mac[15:8];
		12'h6: data <= eth_dst_mac[7:0];
		// ethernet source
		12'h7: data <= eth_src_mac[47:40];
		12'h8: data <= eth_src_mac[39:32];
		12'h9: data <= eth_src_mac[31:24];
		12'ha: data <= eth_src_mac[23:16];
		12'hb: data <= eth_src_mac[15:8];
		12'hc: data <= eth_src_mac[7:0];
		//ether type 08:00
		12'hd: data <= eth_type[15:8];
		12'he: data <= eth_type[7:0];

		// user data packet

		// IPv4 Header
		12'hf: data <= {ip_version, ip_header_len};
		12'h10: data <= ip_dscp_ecn[7:0];
		12'h11: data <= ip_length[15:8];
		12'h12: data <= ip_length[7:0];
		// all zeros
		12'h13: data <= ip_identification[15:8];
		12'h14: data <= ip_identification[7:0];
		// no flags, no frament offset
		12'h15: data <= ip_flags_and_frag[15:8];
		12'h16: data <= ip_flags_and_frag[7:0];
		// time to live
		12'h17: data <= ip_ttl[7:0];
		// protocol UDP
		12'h18: data <= ip_protocol[7:0];
		// header checksum
		12'h19: data <= ip_checksum[15:8];
		12'h1a: data <= ip_checksum[7:0];
		// source address
		12'h1b: data <= ip_src_addr[31:24];
		12'h1c: data <= ip_src_addr[23:16];
		12'h1d: data <= ip_src_addr[15:8];
		12'h1e: data <= ip_src_addr[7:0];
		// dest address
		12'h1f: data <= ip_dst_addr[31:24];
		12'h20: data <= ip_dst_addr[23:16];
		12'h21: data <= ip_dst_addr[15:8];
		12'h22: data <= ip_dst_addr[7:0];
		// no options in this packet

		//
		// UDP/IP header - from port 4096 to port 4096
		// source port 4096
		//12'h23: data <= udp_src_port[15:8];
		// WRITING CLONE ID HERE
		12'h23: data <= index_clone;//udp_src_port[7:0] // <<prev - 1>>
		12'h24: data <= startaddr[19:16];
		12'h25: data <= startaddr[15:8];
		12'h26: data <= startaddr[7:0];
		// UDP length (header + data) 24 octets
		12'h27: data <= udp_length[15:8];//0x04
		12'h28: data <= udp_length[7:0];//0x40
		// udp checksum not suppled
		12'h29: data <= udp_checksum[15:8];//00
		12'h2a: data <= udp_checksum[7:0];//00
		// 0x2a = 42
		//12'h2a: data <= index_clone;
		//
		// finally! 16 bytes of user data
		// defaults to 0000 due to assignment above CASE

// 0x2b == 43 // here, wrong data found...
		12'h2b: begin
						data_user <= 1'b1;
						data <= vramdata;
						end
		12'h2c: data <= vramdata;
		12'h2d:data <= vramdata;
		// ethernet frame check sequence (CRC)
		// will be addedhere, overwriting these nibbles
       // 12'h462:;
       
       // NOTES: THESE MUST BE CHANGED.
		12'h463: begin // == 12'd1123
		          if (flag_max) lastaddr <= 0;
		          else
		         if (vramaddr > 0)
		          lastaddr <= vramaddr - 1'b1;
		         else
		          lastaddr <= 0;
							
				//lastaddr <= vramaddr - 1; 
				data_valid <= 1'b0;
				data_user <= 1'b0;
				almost_sent <= 1'b1;
				end

/*
							----------------------------------------------------------------------------------
							-- End of frame - there needs to be at least 20 octets before  sending
							-- the next packet, (maybe more depending  on medium?) 12 are for the inter packet
							-- gap, 8 allow for the preamble that will be added to the start of this packet.
							--
							-- Note that when the count of 0000 adds one  more nibble, so if start is assigned
							-- '1' this should be minimum that is  within spec.
							----------------------------------------------------------------------------------
 */
 
		12'h479: begin// == 12'd1145
				almost_sent <= 1'b1;
				counter <= 12'b0;// here.
				busy <= 1'b0;
				end
		default: begin 
					data <= vramdata;
				end
		endcase
end
endmodule
