function mrcalc_tag_lines_batch( inDir  )
%MRCALC_TAG_LINES_BATCH Summary of this function goes here
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
    for iFile=1:nFiles
        if strfind(myFiles(iFile,:),'harpData')
            try
                harpDataPath=fullfile(dirName,myFiles(iFile,:));
                load(harpDataPath,'-mat')
                
                %%% PROCESSING %%%
                % get points wit value >pi/2
                tagPointsHarp=zeros(size(harP1));
                tagLinesHarp1=zeros(size(harP1));
                tagLinesHarp2=zeros(size(harP2));
                tagLinesHarp1(harP1>pi/2)=1;
                tagLinesHarp2(harP2>pi/2)=1;
                
                % skeletonize each image
                nTimes = size(harP1,4);
                for iTime=1:nTimes
                    tagLinesHarp1(:,:,1,iTime) = bwmorph(tagLinesHarp1(:,:,1,iTime),'skel',Inf);
                    tagLinesHarp2(:,:,1,iTime) = bwmorph(tagLinesHarp2(:,:,1,iTime),'skel',Inf);
                    tagPointsHarp(:,:,1,iTime) = tagLinesHarp1(:,:,1,iTime) & tagLinesHarp2(:,:,1,iTime);
                    tagPointsHarp(:,:,1,iTime) = bwmorph(tagPointsHarp(:,:,1,iTime),'shrink',Inf);
                end
                %%% END OF PROCESSING %%%
                
                myPath=fullfile(dirName,'tagLinesData.mat');
                save(myPath,'tagLinesHarp1','tagLinesHarp2','tagPointsHarp')
                
            catch ex
                disp(ex.message)
            end

        end
    end
    k=k+1;
    if k>1 %&& mod(k,floor((size(dirs,1)-(iDir-k))/20))==0
        fprintf(' %2.0f%% Approx. remaining time: %.2f minutes \n',100*k/(size(dirs,1)-(iDir-k)), toc*((size(dirs,1)-(iDir-k))/k-1)/60 )
    end
end

disp(['Time in minutes= ',num2str(toc/60)])
disp([num2str(k),' studies processed'])
end

