module Select_Hit(
    select1_i,
    select2_i,
    tag_i,
    ans_select_o
);
input [24:0] select1_i, select2_i, tag_i;
output [1:0] ans_select_o;
reg   s1, s2;

always@(select1_i, select2_i, tag_i, ans_select_o) begin
    s1 = (select1_i[24] && (select1_i[22:0] == tag_i[22:0]));
    s2 = (select2_i[24] && (select2_i[22:0] == tag_i[22:0]));
    // $display("s1 = %d s2 = %d\n",  s1, s2);
end 

assign ans_select_o = s1? 2'b01 : s2 ? 2'b10 : 2'b00;
// assign hit_o = (s1 & s2);

endmodule