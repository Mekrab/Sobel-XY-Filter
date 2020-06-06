`timescale 1ns / 1ps

module Sobel_tb();
reg clk;
reg en;
reg [31:0] stream_input;
wire [31:0] stream_output;

Sobel sobelx(clk, en, stream_input, stream_output);

// generate clock
always begin
    clk = 1; #5; clk = 0; #5;
end

localparam BMP_array_size = 1000*2000;
reg[7:0] bmp_data[BMP_array_size-1:0];
integer bmp_size, bmp_start_pos, bmp_width, bmp_height, biBitCount;

//-----------------------------------------------------------------------
integer i; 
integer j=0;
localparam RESULT_array_size = 1000*2000;
reg[7:0] result[RESULT_array_size-1:0];

always @(posedge clk) begin
    result[j] <= stream_output[7:0];
    j = j+1;
end


//-----------------------------------------------------------------------
task readBMP;
    integer fileID;
    begin
        fileID = $fopen("C:\\Users\\Clarke\\Desktop\\input.bmp", "rb");
        if(fileID == 0) begin
            $display("Open BMP error!\n");
            $finish;
         end else begin
            $fread(bmp_data, fileID);
            $fclose(fileID);
            
            bmp_size = {bmp_data[5], bmp_data[4], bmp_data[3], bmp_data[2]};
            $display("bmp_size =%d!\n",bmp_size);
            bmp_start_pos = {bmp_data[13], bmp_data[12], bmp_data[11], bmp_data[10]};
            $display("bmp_start_pos =%d!\n",bmp_start_pos);
            bmp_width = {bmp_data[21], bmp_data[20], bmp_data[19], bmp_data[18]};
            $display("bmp_width =%d!\n",bmp_width);
            bmp_height = {bmp_data[25], bmp_data[24], bmp_data[23], bmp_data[22]};
            $display("bmp_height =%d!\n",bmp_height);
            biBitCount = {bmp_data[29], bmp_data[28]};
         end
    end
endtask


//-----------------------------------------------------------------------
task writeBMP;
    integer fileID, i;
    begin
        fileID = $fopen("C:\\Users\\Clarke\\Desktop\\output.bmp", "wb");
        
        for(i=0;i<bmp_start_pos;i=i+1) begin
            $fwrite(fileID, "%c", bmp_data[i]);
        end
        
        for(i=bmp_start_pos;i<bmp_size;i=i+1) begin
            $fwrite(fileID, "%c", result[i-bmp_start_pos]);
        end
        
        $fclose(fileID);
        $display("writeBMP: done!\n");
    end
endtask

//-----------------------------------------------------------------------
initial begin
    readBMP;
    #10; 
    en = 1'b0;
    
    for (i=bmp_start_pos; i<bmp_size;i=i+1) begin
        stream_input = {{24{0}}, bmp_data[i]};
        #10;
        en = 1'b1;
    end
    
    #10; 
    en = 1'b0;
    
    #10
    writeBMP;
    #10;
    $stop;
end
endmodule
