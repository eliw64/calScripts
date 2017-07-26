function info = readDAQdata(varargin)
% info = readDAQdata
% info = readDAQdata(filename)
% info = readDAQdata(filedir,filename)
%
% This is a function to read a h5 file in for processing. All output data
% is taken from the h5 file and loaded into a struct called info.
%
% 1. If no filename is given then a user interface is loaded to find the file.
% 2. If only the filename is provided, the file should be in a directory
%    reachable by readDAQdata
%
%
% INPUTS:
%       filename: filename, as a string
%       filedir: location, as a string
%
% OUTPUTS:
%       info: struct with fields from the data in filename
%
% Jason Kulpe
% 5/2/2017



%% FIXED THINGS

% conversion factor
bits2volt = 2/(2^15-1);
e = datenum('01-jan-1970 00:00:00');




%% CHECK INPUTS

if nargin == 0
    [filename, filedir] = uigetfile('*.h5');
elseif nargin == 1
    filedir = cd;
    filename = varargin{1};
elseif nargin == 2
    filedir = varargin{1};
    filename = varargin{2};
else
    error('Improper number of input arguments');
end

% check
if ischar(filename) && ischar(filedir)
    full = fullfile(filedir,filename);
else
    error('Filename and filedir should be strings');
end


%% READ ATTRIBUTES

% attributes to read and class
%
% test things
% * type (string)
% * test_description (string)
% * utc_time (double)
% * waveform_description (string)
%
% channel things
% * channel_names (cell array of strings)
% * channel_serial_numbers (cell array of strings)
% * channel_daq_indexes (double array)
% 
% other things
% * rx_boom_arm_angle_deg (double)
% * tx_boom_arm_angle_deg (double)
% * depth_m (double)
% * temp_deg_c (double)
% 
% capture things
% * capture_[n] (double array)
% * window_length (double)
% * window_offset (double)
% * utc_time (double) 
% * sample frequency (double)
% * t (double array)

info = struct;

% test things
s = h5readatt(full,'/','type');
info.type = s{:};
s = h5readatt(full,'/','test_description');
info.test_description = s{:};
s = h5readatt(full,'/','waveform_description');
info.waveform_description = s{:};
info.utc_time = utc(h5readatt(full,'/','utc_time'));

% channel things
info.channel_names = h5readatt(full,'/','channel_names');
info.channel_serial_numbers = h5readatt(full,'/','channel_serial_numbers');
info.channel_daq_indices = double(h5readatt(full,'/','channel_daq_indexes'));

% other things
info.rx_boom_arm_angle_deg = h5readatt(full,'/','rx_boom_arm_angle_deg');
info.tx_boom_arm_angle_deg = h5readatt(full,'/','tx_boom_arm_angle_deg');
info.depth_m = h5readatt(full,'/','depth_m');
info.temp_deg_c = h5readatt(full,'/','temp_deg_c');

%% READ CAPTURES

% read the number of capture things
capture_name = h5readatt(full,'/','capture_names');
info.num_captures = length(capture_name);
info.captures_V = [];

% read all captures and covert to volts
for i = 1:info.num_captures
    nm = ['/capture_',num2str(i)];
    bits = h5read(full,nm);
    info.captures_V(i,:,:) = bits2volt * double(bits');
    
    % things that may vary between 
    info.window_length_s = h5readatt(full,nm,'window_length');
    info.window_offset_s = h5readatt(full,nm,'window_offset');
    info.capture_utc_time{i} = utc(h5readatt(full,nm,'utc_time'));
    info.sample_frequency_Hz = h5readatt(full,nm,'sample_frequency');
end

dt = 1/info.sample_frequency_Hz;
N = size(info.captures_V,3); % number of time samples
info.t = 0:dt:((N-1)*dt);




    function out = utc(in)
        % convert seconds since 1/1/70 into today's time
        out = datestr(e+in/86400,30);
    end




end