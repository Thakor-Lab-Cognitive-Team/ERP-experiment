function [X, Y] = SEM(data)
% mean and standard error
X = mean(data);
X = X';
sem = std( data ) / sqrt( length( data ));
Y = sem';
end