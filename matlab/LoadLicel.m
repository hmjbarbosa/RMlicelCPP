function data = LoadLicel(FileName);
%function data = LoadLicel(FileName);
%
% Description:
% Function that Loads Licel data recorded by Licel VI's
%
% Input Parameters:
% FileName: The LICEL File Name
%
% Output Structure:
%
% data
%     |
%     |
%     |_ GlobalParameters
%     |                 |_ HeightASL       : Station Height             [m]
%     |                 |_ Latitude        : Station Latitude         [deg]
%     |                 |_ Longitude	   : Station Longitude        [deg]
%     |                 |_ ZenithAngle     : Laser Zenith Angle       [deg]
%     |                 |_ Laser1Shots     : Number of Acquired Shots   [-]
%     |                 |_ Laser1Frequency : Laser Repetition Rate     [Hz]
%     |                 |_ Laser2Shots     : Number of Acquired Shots   [-]
%     |                 |_ Laser2Frequency : Laser Repetition Rate     [Hz]
%     |                 |_ Channels        : Active Channels            [-]
%     |
%     |_ Channel
%               |_ isActive         : Is it active? (T/F)               [-] 
%               |_ isPhotonCounting : Is PhCount (T) or Analog (F)?     [-]
%               |_ LaserNumber      : To which Laser is it associated?  [-]
%               |_ Bins             : Number of acquired bins           [-]
%               |_ isHV             : (T) for HV on                     [-]
%               |_ Votage           : Voltage of the PMT / APD          [V]
%               |_ BinSize          : Size of the bin                   [m]
%               |_ Wavelength       : Detection wavelength             [nm]
%               |_ ADC              : Number of eq. bits of the ADC     [-]
%               |_ Shots            : Number of acquired shots          [-]
%               |_ Scale            : Voltage scale or Threshold level [mV]
%               |_ Transient        : Associated transient recorder     [-]
%               |_ Signal           : Signal                 [mV] or [MCPS]
%               |_ Range            : Altitude Scale                [m AGL]
%               |_ Time             : Time Scale from first record  [hours]
%
% or data = -1 if there is an error

if nargin==0
	[FileName,DirName] = uigetfile('*.*','Select the LICEL Files','MultiSelect','on');
	if ~iscell(FileName)
		FileName={FileName};
	end
	FileName = sort(FileName);
	FileName = strcat(DirName,FileName');
end


for k=length(FileName):-1:1
	%Reverse order to allocate memory from the beginning making the
	%loading procedure faster

	fid = fopen(FileName{k},'r');
	[pathstr, name, ext] = fileparts(FileName{k});
	Name = strcat(name,ext);
	
	if fid ~=-1

		%Load LICEL Global parameters (created in Datafiles globallines.vi)
		data.GlobalParameters.Name(k,:) = fscanf(fid,'%s',1);							% File name

		if strcmpi(Name,data.GlobalParameters.Name(k,:));
			fseek(fid,80+1,'bof');
			data.GlobalParameters.Station{k}			= fscanf(fid,'%s',1);			% Station name
			Day											= fscanf(fid,'%s',1);			% Start date
			Time										= fscanf(fid,'%s',1);			% Start time
			data.GlobalParameters.Start(k,:)		...
				= datestr(datenum([Day ' ' Time], 'dd/mm/yyyy HH:MM:SS'),'dd/mm/yyyy HH:MM:SS');
			Day											= fscanf(fid,'%s',1);			% End date
			Time										= fscanf(fid,'%s',1);			% End time
			data.GlobalParameters.End(k,:)			...
				= datestr(datenum([Day ' ' Time], 'dd/mm/yyyy HH:MM:SS'));
			data.GlobalParameters.HeightASL(k,:)		= fscanf(fid,'%f',1);			% Altitude
			data.GlobalParameters.Latitude(k,:)			= fscanf(fid,'%s',1);			% Latitude
			data.GlobalParameters.Longitude(k,:)		= fscanf(fid,'%s',1);			% Longitude
			data.GlobalParameters.ZenithAngle(k,:)		= fscanf(fid,'%f',1);			% Zenith angle
			data.GlobalParameters.Laser1Shots(k,:)		= fscanf(fid,'%f',1);			% Number of shots 1
			data.GlobalParameters.Laser1Freq(k,:)		= fscanf(fid,'%f',1);			% Frequency 1
			data.GlobalParameters.Laser2Shots(k,:)		= fscanf(fid,'%f',1);			% Number of shots 1
			data.GlobalParameters.Laser2Freq(k,:)		= fscanf(fid,'%f',1);			% Frequency 1
			data.GlobalParameters.Channels(k,:)			= fscanf(fid,'%f',1);			% Number of channels

			%Load LICEL Transient Parameters (created in Datafiles variablelines.vi)
			for i=1:data.GlobalParameters.Channels(k)
				data.Channel(i).isActive(k,:)			= fscanf(fid,'%f',1)'==1;		% is Active Channel?
				isPhC									= fscanf(fid,'%f',1)';			% is Photon Counting?
				data.Channel(i).isPhotonCounting(k,:)   = isPhC==1;
				data.Channel(i).LaserNumber(k,:)		= fscanf(fid,'%f',1)';			% Laser Number
				data.Channel(i).Bins(k,:)				= fscanf(fid,'%f',1)';			% Number of bins
				data.Channel(i).isHV(k,:)				= fscanf(fid,'%f',1);			% is HV on?
				data.Channel(i).Votage(k,:)				= fscanf(fid,'%f',1)';			% HV Voltage [V]
				data.Channel(i).BinSize(k,:)			= fscanf(fid,'%f',1)';			% Bin Size [m]
				data.Channel(i).Wavelength(k,:)			= fscanf(fid,'%i',1)';			% Wavelength [nm]
				data.Channel(i).isParallel(k,:)			= fscanf(fid,'.%c')=='p';		% is Parallel Polarisation?
				fseek(fid,11,'cof');													% Jump '0 0 00 000'
				data.Channel(i).ADC(k,:)				= fscanf(fid,'%f',1)';			% ADC Equivalent Resolution [bits]
				data.Channel(i).Shots(k,:)				= fscanf(fid,'%f',1)';			% Acquired Shots
				Scale									= fscanf(fid,'%f',1);			% Voltage Scale ...
				data.Channel(i).Scale(k,:)				= Scale * ...					% or Discriminator Level...
														((1000 * ~isPhC) + isPhC);		% [mV]
				fseek(fid,3,'cof');														% Jump 3 bytes
				data.Channel(i).Transient(k,:)			= fscanf(fid,'%f',1);			% Transient Number
			end

			fseek(fid,80*(data.GlobalParameters.Channels(k)+3),'bof');					% Go to end of header

			%Load LICEL Channels (created in Datafile Store Binary Data.vi)

			for i=1:data.GlobalParameters.Channels(k)
				fseek(fid,2,'cof');														% Skip CR/LF

				if data.Channel(i).isPhotonCounting(k)
					ScaleFactor = 150/data.Channel(i).BinSize(k);						% Signal [MCPS] (Mega Counts Per Second)
				else
					ScaleFactor = data.Channel(i).Scale(k) / ...
						2^data.Channel(i).ADC(k);										% Signal [mV].
				end

				DataVector = fread(fid, data.Channel(i).Bins(k), 'long');				% Retrieve the channel bin information
				data.Channel(i).Signal(:,k)	= DataVector * ScaleFactor...
					/data.Channel(i).Shots(k);											% Signal [MCPS] or [mV]
				data.Channel(i).Range(:,k)	= (1:data.Channel(i).Bins(k))'*...
											data.Channel(i).BinSize(k);					% Range [m]
				data.Channel(i).Time(k,:) =	...
								(datenum(data.GlobalParameters.Start(k,:)) + ...
								 datenum(data.GlobalParameters.End(k,:)  ) )/ 2;
			end
			fclose(fid);
		end
	end
end

% %Eliminate Redundant data in the Global Parameters
% fields = fieldnames(data.GlobalParameters);
% for k=1:length(fields)
% 	V = unique(data.GlobalParameters.(fields{k}));										% If all the files have the same
% 	if length(V) == 1;																	% Global Parameters
% 		data.GlobalParameters.(fields{k}) = V;											% Leave only one record
% 	end
% end
% if length(data.GlobalParameters.Station)==1
% 	data.GlobalParameters.Station = data.GlobalParameters.Station{1};
% end

% %Eliminate Redundant data in the Channel Specification
% fields = fieldnames(data.Channel);
% for i=1:length(data.Channel)
% 	for k=1:length(fields) - 3
% 		V = unique(data.Channel(i).(fields{k}));
% 		if length(V) == 1;													
% 			data.Channel(i).(fields{k}) = V;								
% 		end
% 	end
% end
% 
% %Create one Z axis for variable if possible
% for k=1:data.GlobalParameters.Channels(1)
% 	V = unique(data.Channel(k).Range','rows')';
% 	if size(V,2)==1;
% 		data.Channel(k).Range = V;
% 	end
% end

for i=1:length(data.Channel)
	data.Channel(i).Time = 24 * (data.Channel(i).Time - data.Channel(i).Time(1));
end
	