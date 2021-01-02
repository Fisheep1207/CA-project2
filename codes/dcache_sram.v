module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   [24:0]    tag_o;
output   [255:0]   data_o;
output             hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];    
reg      [255:0]   data[0:15][0:1];

reg                LRU[0:15];

integer            i, j;

wire  [1:0]   select_o;


Select_Hit SH(tag[addr_i][0], tag[addr_i][1], tag_i, select_o);

initial begin
    for (i=0;i<16;i=i+1)begin
        LRU[i] = 1'b1;
    end
end

// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if(hit_o) begin
            if(select_o == 2'b01) begin
                tag[addr_i][0] = tag_i;
                data[addr_i][0] = data_i;
                LRU[addr_i] = 1;
            end
            else if (select_o == 2'b10) begin
                tag[addr_i][1] = tag_i;
                data[addr_i][1] = data_i;
                LRU[addr_i] = 0;
            end
        end
        else begin
            tag[addr_i][LRU[addr_i]] = tag_i;
            data[addr_i][LRU[addr_i]] = data_i;
            LRU[addr_i] ^= 1;
        end
    end
    else if (enable_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if(hit_o) begin
            if(select_o == 2'b01) begin
                LRU[addr_i] = 1'b1;
            end
            else if (select_o == 2'b10) begin
                LRU[addr_i] = 1'b0;
            end
        end
        else begin
            LRU[addr_i] ^= 1'b1;
        end
    end
end

// Read Data      
// TODO: tag_o=? data_o=? hit_o=?

assign tag_o  = (select_o == 2'b01)? tag[addr_i][0]: (select_o == 2'b10) ? tag[addr_i][1]: tag[addr_i][LRU[addr_i]];
assign data_o = (select_o == 2'b01)? data[addr_i][0]: (select_o == 2'b10) ? data[addr_i][1]: data[addr_i][LRU[addr_i]];
assign hit_o  = (select_o == 2'b10 || select_o == 2'b01 )? 1'b1 : 1'b0;

endmodule