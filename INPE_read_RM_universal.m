function exported =  INPE_read_RM_universal(varargin);

% data =  INPE_read_RM_Manaus(varargin:fnn,lengthlimit)
%
% reads a RM*.* file for signals and parameters.
% Input: complete filename as string
% Output: struct containing the parameters, info and data.
% %
% the profile data are
%   - analogue
%    -photon counting with dead time correction
%
% Note: no background correction and no gluing!
%
% output is a struct called data where:
% - params: are the parameters of the measurements
% - laser: contains the laser characteristics
% - acq(N): contain the profiles and data processing relevant data
%
% Riad Bourayou, 
%   v1. INPE CPTEC/DSA june 2011
%   v2. IPEN/CLA Sept. 2012
% riad.bourayou(a)gmail.com


%% Parse the entries of the program
%
% options are:
%   fnn: filename (if none, then open dialog)
%   lengthlimit: load the whole profile or limit to first points?
%   channels: some RM files have 3 channels, some have more. Decide which
%             to load.

p = inputParser;
p.addOptional('fnn','',@ischar);
p.addOptional('lengthlimit',0,@isnumeric);

p.parse(varargin{:});
defaultvalues = {'' 0};
[ fnn,lengthlimit ]= defaultvalues{:};
Results2=struct2cell(p.Results);
[fnn,lengthlimit ]=deal(Results2{:});
clear p Results2 defaultvalues


%% OPEN FILE
if ~length(fnn)
    [fnn, pnn]=uigetfile('*.*', 'Choose a Raymetrics file');
    fnn=[pnn fnn];
end
fid=fopen(fnn,'r');



%% now let's read the PARAMS of this measurement

params.savedfilename=fscanf(fid,'%s',1);
params.site=fscanf(fid,'%s',1);
params.date_start=fscanf(fid,'%2d/%2d/%4d',3); %% DD MM YY

if ~length(params.date_start) % usually happens if the name of the site
    frewind(fid);              % contains a space, something to avoid!
    params.savedfilename=fscanf(fid,'%s',1);
    params.site=[fscanf(fid,'%s',1) fscanf(fid,'%s',1)];
    params.date_start=fscanf(fid,'%2d/%2d/%4d',3); %% DD MM YY
end
    

params.hour_start=fscanf(fid,'%2d:%2d:%2d',3); %% hh mn ss
params.date_end=fscanf(fid,'%2d/%2d/%4d',3); %% DD MM YY
params.hour_end=fscanf(fid,'%2d:%2d:%2d',3); %% hh mn ss

params.local_altitude=fscanf(fid,'%d',1);
params.longitude=fscanf(fid,'%f',1);
params.latitude=fscanf(fid,'%f',1);

if strcmp(params.site,'CUBATAO')
    fscanf(fid,'%d',4);
else
    params.zenith_angle=fscanf(fid,'%d',1);
    params.azimutal=fscanf(fid,'%d',1);
    params.T0=fscanf(fid,'%f',1);
    params.P0=fscanf(fid,'%f',1);
    laser.averaged_shots1=fscanf(fid,'%d',1);
    laser.frequency_shots1=fscanf(fid,'%d',1);
    laser.averaged_shots2=fscanf(fid,'%d',1);
end

laser.frequency_shots2=fscanf(fid,'%d',1);
params.number_channels=fscanf(fid,'%d',1);
params.start=datenum([params.date_start(3:-1:1); params.hour_start]');
params.end=datenum([params.date_end(3:-1:1); params.hour_end]');
rmfield(params, {'date_start' 'hour_start' 'date_end' 'hour_end'}) ;




%% parameters of individual channels

for canal = 1:params.number_channels
    acq(canal).is_active=fscanf(fid,'%d',1);
    acq(canal).is_photocnt=fscanf(fid,'%d',1);
    acq(canal).using_source_number=fscanf(fid,'%d',1);
    acq(canal).n_bins=fscanf(fid,'%d 1',1);
    acq(canal).detector_voltage=fscanf(fid,'%d',1);
    acq(canal).spatialresolution=fscanf(fid,'%f',1);
    acq(canal).wavelength=fscanf(fid,'%5d.',1);
    acq(canal).polarisatn=fscanf(fid,'%s 0 0 00 000 ',1);
    acq(canal).ADCbits=fscanf(fid,'%d',1);
    acq(canal).averaged_shots=fscanf(fid,'%d',1);
    acq(canal).discr_level=fscanf(fid,'%f',1);
    % analog input range in Volt in case of analog dataset , discriminator level
    % in case of photon counting, one digit dot 3 digits.
    acq(canal).descriptor=fscanf(fid,' %2c',1);
    acq(canal).TRdescriptor=fscanf(fid,'%1d',1);
    % Dataset descriptor BT  analog dataset, BC  photoncounting, the number is the transient
    % recorder number as a hexadecimal.
    
end
exported.params=params;
exported.laser=laser;

% drop 1 line before data starts
fgetl(fid); % completes current line

%% data of individual channels
for canal = 1:params.number_channels
    
    % skip CR
    fgetl(fid);
    
    % read n_bins data
    data=fread(fid,acq(canal).n_bins,'int32');
    
    % correct data according to type: PC or analog
    if (acq(canal).is_photocnt==0) % analog
        dScale = 2^(-acq(canal).ADCbits)*(acq(canal).discr_level*1.e3)/acq(canal).averaged_shots;
        data=data*dScale;
    else % photon counting or APD
        data = data * ...
            (7.5/acq(canal).spatialresolution)*20./acq(canal).averaged_shots;
        % corrects for the dead counts supposing a non-paralysable
        data=(data/1-data*5e-9);
    end
    acq(canal).profile=data;
    acq(canal).altitudes=acq(canal).spatialresolution*(1:acq(canal).n_bins)';
    
    % plot to check
    %     figure
    %     plot(data)
    %     title(num2str(canal))
    
    exported.acq(canal)=acq(canal);
    
end



%% End
fclose(fid); 
