function readData(src, ~)
    data = readline(src);
    src.UserData.data(end+1) = str2double(data);
    src.UserData.count = src.UserData.count + 1;
end