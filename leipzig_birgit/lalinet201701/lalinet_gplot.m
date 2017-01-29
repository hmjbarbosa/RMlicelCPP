%clear all
%close all

addpath ../../matlab
addpath ..
addpath ../sc
    
flist{1}='Argentina_Aeroparque';
flist{2}='Argentina_Bariloche' ;
flist{3}='Argentina_Comodoro'  ;
flist{4}='Argentina_Gallegos'  ;
flist{5}='Bolivia'             ;
flist{6}='Brasil_SP'           ;
flist{7}='Chile_PuntaArenas'   ;
flist{8}='Colombia'            ;
nfiles=length(flist);

for nf=7:7 %1:nfiles
    
    disp(['File= ' flist{nf}])
    % load mat file
    x=load(flist{nf});

    % get julian dates
    ntimes=length(x.(flist{nf}).head);
    disp(['# prof in file= ' num2str(ntimes)])
    clear jd;
    for nt=1:ntimes
        jd(nt)=x.(flist{nf}).head(nt).jdi;
    end
    
    % list days in file
    dlist=unique(floor(jd));
    ndays=length(dlist);
    disp(['# days in file= ' num2str(ndays)])
    disp(['first day= ' datestr(dlist(1))])
    disp(['last  day= ' datestr(dlist(end))])

    % look for each channel
    nchanel=x.(flist{nf}).head(1).nch;
    for nc=1:nchanel
        disp(['Now on channel= ' num2str(nc)])
        anpc=x.(flist{nf}).head(1).ch(nc).photons;
        if anpc==1; anpc='PC'; else anpc='AN'; end
        wlen=x.(flist{nf}).head(1).ch(nc).wlen;

        rangebins=x.(flist{nf}).head(1).ch(nc).ndata;
        dz=x.(flist{nf}).head(1).ch(nc).binw/1e3;
        z=[1:rangebins]'*dz;
        z2=z.*z;

        z=binning(z,8,1);
        z2=binning(z2,8,1);
        
        % loop to create figures
        for nd=1:1%ndays
            disp(['  day=' datestr(dlist(nd))]);

            tmp=datevec(dlist(nd));
            fname=sprintf('%s_%04d-%02d-%02d_%04dnm_%s.png',...
                          flist{nf},tmp(1),tmp(2),tmp(3),wlen,anpc); 

            if exist([flist{nf} '/' fname],'file')
                continue
            end
            
            % mask
            mask=jd>=dlist(nd) & jd<=(dlist(nd)+1) ;

            % process data
            [Praw, times]=bins(dlist(nd),dlist(nd)+1,5,...
                               x.(flist{nf}).head, ...
                               x.(flist{nf}).chphy(nc).data);

            %[Pbg, bg]=remove_bg(x.(flist{nf}).chphy(nc).data,500,3);
            [Pbg, bg]=remove_bg(Praw,500,-10);
            Pbg=binning(Pbg,8,1);
            Pbg(Pbg<=0)=nan;
            
            clear Pbgr2
            for nt=1:length(times)%ntimes
                Pbgr2(:,nt)=Pbg(:,nt).*z2(:,1)*1e6;
            end
            if all(isnan(Pbgr2(:)))
                continue
            end

            figure(mod(nd,10)+1); clf;
            temp=get(gcf,'position'); temp(3)=900; temp(4)=300;
            set(gcf,'position',temp); % units in pixels!
            set(gca,'position',[0.07 0.12 0.84 0.75])  
            %[h,bar]=gplot2(log10(Pbgr2(:,mask)),[], find(mask), z);
            [h,bar]=gplot2(log10(Pbgr2),[], times, z);
            datetick('x',15, 'keeplimits')
            grid on; box on;
            ylabel('Range (km)');ylim([0 10])
            ylabel(bar,'Log(P r^2) [a.u.]'); 
            
            title([flist{nf} sprintf(' %04d-%02d-%02d',tmp(1),tmp(2),tmp(3)) ...
                   sprintf(' %4d nm %s',wlen,anpc)]); 
            %prettify(gca,bar); grid on; 

            %fname=sprintf('%s_%04d-%02d-%02d_%04dnm_%s.png',...
            %             flist{nf},tmp(1),tmp(2),tmp(3),wlen,anpc); 

            screen2png([flist{nf} '/' fname]);
            
            % return
        end
    end
end

%