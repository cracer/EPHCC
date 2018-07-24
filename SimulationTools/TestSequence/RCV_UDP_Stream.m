%% Copyright 2018 Alliance for Sustainable Energy, LLC
%
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
% and associated documentation files (the "Software"), to deal in the Software without restriction, 
% including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
% and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
% subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
% BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS, THE COPYRIGHT HOLDERS, THE UNITED STATES, 
% THE UNITED STATES DEPARTMENT OF ENERGY, OR ANY OF THEIR EMPLOYEES BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%
% Author: Przemyslaw Koralewicz / NREL
% Date: 2017

clear all;

BANSHEEUDP = BANSHEE_Frame();

% Temp - example frame
% datastring = 'afaf000002000000950600000300000001000000010000002f0000000a0000000a00000064000000640000000000000001000000640000006400000001000000640000006400000064000000640000006400000064000000640000006400000064000000020000000000000003000000e80300000200000024000000010000000800000001000000000000000000000000000000e8370000d8140000e11b0000af220000f2220000ef14000092140000a41400000c220000f9660000d3300000153b0000372200007b2200004e0a0000ac3700008e14000083220000e50d000064000000b40d000000000000c72200003d1800000000000000000000df170000ab2100006a340000dd66000035000000780a0000ea290000e45d0000ad0800000000000000000000bd290000000000003200000000000000612100005b8b0000dcd20000819b00000000000000000000ce1900008d090000ca0c00000110000019100000ab0900007509000080090000b50f0000a22e0000ac160000481b0000ba0f0000f00f0000bd0400007e19000076090000db0f000067060000620000005006000000000000091000002f0b00000000000000000000000b00009e0f00002e1800002b2f000031000000d104000055130000d62a0000000400000000000000000000d6120000310000000000000000000000660f00002a4000009f6000008d470000000000000000000063000000630000006300000063000000630000006300000062000000620000006200000063000000630000006300000062000000620000006200000062000000620000006300000063000000630000006200000062000000630000006300000062000000620000006200000062000000630000006300000063000000630000006300000062000000620000006200000062000000620000006200000063000000620000006100000063000000630000006300000063000000630000006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f170000701700006f1700006f1700006f1700006f1700006f1700006f1700006f1700006f170000701700006f1700006f1700006f1700006f1700006f1700007017000070170000701700007017000070170000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000010000000100000001000000000000000100000001000000000000000000000001000000010000000100000001000000010000000100000001000000010000000100000000000000000000000100000000000000010000000000000001000000010000000100000001000000000000000000000000000000e80300006300000063000000ddffffff000000000000000000000000d007000000000000c7110100152d05000000000001000000000000008c0300008d0300008c03000001000000010000000100000001000000010000000100000009010000db00000004010000080200005d0100000e0200005003000057030000610300000c02000060020000610300002504000016050000690300007003000074030000c0020000d9010000cc000000cb000000d5010000d7010000d7010000cf010000d4010000d4010000d5010000d5010000d4010000d9010000d5010000d6010000d8010000d9010000d80100000000000000000000000000000000000000000000000000000000000000000000555500002ad60000';
% for i=1:2:length(datastring)
%    u8data((i+1)/2) = uint8(hex2dec(datastring(i:i+1)));
% end

T0 = now;
udp=pnet('udpsocket',7200)
len=pnet(udp,'readpacket');
while(len>0)
    u8data=pnet(udp,'read',2000,'uint8');
    len=pnet(udp,'readpacket');
    disp('.');
end

%try

    for i=1:200
        len=pnet(udp,'readpacket');
        if len>0
            u8data=pnet(udp,'read',2000,'uint8');
            [datastruct header] = UDP_decode(BANSHEEUDP, u8data);
            timestamp = round((now-T0)*24*60*60*1000);
            filenames = fieldnames(datastruct);
            for jj=1:length(filenames)
                newrow = [timestamp eval(['datastruct.' filenames{jj}])];
                if exist(filenames{jj},'var')
                    eval([filenames{jj} '= [' filenames{jj} ';newrow];']);
                else
                    eval([filenames{jj} '= newrow;']);
                end
            end
            disp([num2str(i) ':' num2str(datastruct.misc_2)]);
        end
        pause(0.001);
    end
    disp('Data capture complete. Closing port...');
    pnet(udp, 'close');
%catch
   %always close port
   %disp('Error during data capture. Closing port...');
   % pnet(udp, 'close');
%end;
%% Store data to .dat files
for jj=1:length(filenames)
    if exist(filenames{jj},'var')
        dlmwrite([filenames{jj} '.dat'],eval(filenames{jj}),'newline','pc');
    end;
end
save header.mat header;
