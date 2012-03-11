function mrcalc_harp_batch( inDir )
%MRCALC_HARP_BATCH Summary of this function goes here
%   Detailed explanation goes here
%   author: Konrad Werys (konradwerys@gmail.com)

addpath(fullfile('..','mrtoolbox'))

dirs = get_all_dirs(inDir);
nDirs=size(dirs,1);
k=0;

tic
for iDir=1:nDirs
    dirName = cell2mat(dirs(iDir));
    myFiles=ls(dirName);
    nFiles=size(myFiles,1);
    idxMrData=0;
    idxDcmData=0;
    for iFile=1:nFiles
        if strfind(myFiles(iFile,:),'mrData')
            idxMrData = iFile;
        end
        if strfind(myFiles(iFile,:),'dcmData')
            idxDcmData = iFile;
        end
    end
    if idxMrData && idxDcmData
        try
            mrDataPath=fullfile(dirName,myFiles(idxMrData,:));
            dcmDataPath=fullfile(dirName,myFiles(idxDcmData,:));
            load(mrDataPath,'-mat')
            load(dcmDataPath,'-mat')
            
            tagSpacing = [6 6];
            pixelSpacing = dcmTags{1}.PixelSpacing';
            gridAngle = pi/4;
            filterRadius = 7;
            [harP1,harP2,harM1,harM2,myFilter] = mrcalc_harp( mrData, tagSpacing, pixelSpacing, gridAngle, filterRadius );
            myPath=fullfile(dirName,'harpData.mat');
            save(myPath,'harP1','harP2','harM1','harM2','myFilter','mrData')
            disp(['Saved: ', myPath])
            subplot(2,3,1),imshow(mrData(:,:,1,1),[])
            subplot(2,3,2),imshow(harP1(:,:,1,1),[])
            subplot(2,3,5),imshow(harP2(:,:,1,1),[])
            subplot(2,3,3),imshow(harM1(:,:,1,1),[])
            subplot(2,3,6),imshow(harM2(:,:,1,1),[])
            %
            subplot(2,3,4),
            F=fft2(mrData(:,:,1,1));F(1,1)=0;
            imshow(fftshift(abs(F)),[]);hold on
            contour(myFilter(:,:,1,1),1);colormap jet;alpha(0.6);hold off
            %
            pause(.1)
            k=k+1;
            clear harP1 harP2 harM1 harM2 dcmData mrData dcmTags
        catch ex
            disp(ex.message)
        end
    end
    if k>1 && mod(k,floor((size(dirs,1)-(iDir-k))/20))==0 
        fprintf(' %2.0f%% Approx. remaining time: %.2f minutes \n',100*k/(size(dirs,1)-(iDir-k)), toc*((size(dirs,1)-(iDir-k))/k-1)/60 )
    end
end

disp(['Time in minutes= ',num2str(toc/60)])
disp([num2str(k),' studies processed'])

end

