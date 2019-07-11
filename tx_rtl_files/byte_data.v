 module byte_data(
	input wire clk,
	input wire start,
	input wire advance,
	input wire [15:0] aux, // auxiliary number
	input wire [15:0] segment_num,
	input wire [7:0] index_clone,
	input wire [7:0] qos,
	(* mark_debug = "true" *) input wire [7:0] vramdata,
	input wire [15:0] startaddr, // coordinate

	(* mark_debug = "true" *) output reg busy = 1'b0,
	(* mark_debug = "true" *) output reg [7:0] data = 8'b0,
	
	output reg [11:0] counter = 12'b0,
	output reg data_user = 1'b0,
	(* mark_debug = "true" *) output reg data_valid = 1'b0,
	output reg data_enable = 1'b0
	);
//parameter VGA_ -> 420*240
parameter xmax = 320;
parameter ymax = 180;


parameter ip_header_bytes = 20;
parameter udp_header_bytes = 8;
parameter data_bytes = 1440; // 1444 Bytes. 4: my protocol, 1440: payload.  
parameter ip_total_bytes = ip_header_bytes + udp_header_bytes + data_bytes;//20 + 8 + 1444 = 1472 = x5c0
parameter udp_total_bytes = udp_header_bytes + data_bytes; // 8 + data_bytes = 1452 = x5ac
reg start_internal = 1'b0;

reg [7:0] index_clone_rised;

// ethernet frame header
reg [47:0] eth_src_mac = 48'hdeadbeef0123;
reg [47:0] eth_dst_mac = 48'hffffffffffff;
reg [15:0] eth_type = 16'h0800;

// ip header
reg [3:0] ip_version = 4'h4;
reg [3:0] ip_header_len = 4'h5;

//reg [7:0] ip_dscp_ecn = 8'h00;// 00 - 02 :
wire [7:0] ip_dscp_ecn = qos;
reg [15:0] ip_identification = 16'h0000;
reg [15:0] ip_length = ip_total_bytes;
reg [15:0] ip_flags_and_frag = 16'h4000;//断片化禁止
reg [7:0] ip_ttl = 8'd2;
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
	 // 4500 + 0030 + 4422 + 4000 + 8006 + 0000 + (0410 + 8A0C + FFFF + FFFF) = 0002BBCF (32-bit sum)

assign ip_checksum1 = 32'd0 + {ip_version, ip_header_len, ip_dscp_ecn} + ip_identification
				+ ip_length + ip_flags_and_frag + {ip_ttl, ip_protocol}
				+ ip_src_addr[31:16] + ip_src_addr[15:0] + ip_dst_addr[31:16]
				+ ip_dst_addr[15:0];

	 //0002 + BBCF = BBD1 = 1011101111010001 (1's complement 16-bit sum, formed by "end around carry" of 32-bit 2's complement sum)
assign ip_checksum2 = ip_checksum1[31:16] + ip_checksum1[15:0];
	 //~BBD1 = 0100010000101110 = 442E (1's complement of 1's complement 16-bit sum)
assign ip_checksum  = ~ip_checksum2;
reg flag_max = 0;

always @(posedge clk) begin
	// update the counter
	if (start == 1'b1) begin
		index_clone_rised <= index_clone;
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

	data <= 8'b00000000;
	case (counter)
		// pause at 0count when idle
		12'h0:  begin// must be NULL???????
						//mydata_rised <= mydata;
						
						//index_clone_rised <= index_clone;
				end
		12'h1: begin
				//busy <= 1'b1;
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
		12'h1f: data <= ip_dst_addr[31:24]; // c0
		12'h20: data <= ip_dst_addr[23:16]; // a8
		12'h21: data <= ip_dst_addr[15:8]; // 01
		12'h22: data <= ip_dst_addr[7:0]; // 02
		// no options in this packet


		12'h23: data <= segment_num[15:8]; // UDP SOURCE [15:8]
		12'h24: data <= segment_num[7:0]; // UDP SOURCE [7:0]
		12'h25: data <= index_clone; // UDP DST [15:8]
		12'h26: data <= aux[15:8]; // UDP DST[7:0]


		// UDP length (header + data) 24 octets
		12'h27: data <= udp_length[15:8];//05
		12'h28: data <= udp_length[7:0];//a8
		// udp checksum not suppled
		12'h29: data <= udp_checksum[15:8];//00
		12'h2a: data <= udp_checksum[7:0];//00

		12'h2b: begin
						//data <= startaddr[23:16];
						data <= aux[7:0];
						end
		12'h2c: data <= startaddr[15:8];
		12'h2d:data <= startaddr[7:0];
		// 0x2e == 46: begin pixcel data
		12'h2e:begin
		data_user <= 1'b1;
		data <= vramdata; // here.
		end

		12'h5cb: begin //1483

							
				data_valid <= 1'b0;
				data_user <= 1'b0;
				end

 
		12'h5e1: begin
				counter <= 12'b0;
				busy <= 1'b0;
				end
		default: begin 
					data <= vramdata;
				end
		endcase
end
endmodule
