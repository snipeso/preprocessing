   fid = fopen([Filepath, Filename], 'rb', 'b');
[segInfo, dataFormat, header_array, EventCodes, Samp_Rate, NChan, scale, NSamp, NEvent] = readRAWFileHeader(fid)
  fclose(fid);