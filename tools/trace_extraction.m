function roi_list=trace_extraction(roi_list, save_keyword)
% Hua-an Tseng, huaantseng at gmail
    
    [selected_files,selected_folder] = uigetfile('*.tif','MultiSelect','on');

    if class(selected_files)=='char'
        file_list(1).name = selected_files;
    else
        file_list = cell2struct(selected_files,'name',1);
    end

    whole_tic = tic;
    
    cd(selected_folder);
    
    for file_idx=1:length(file_list)
        
        
        filename = file_list(file_idx).name;
        fprintf(['Processing ',filename,'....\n']);
        
        InfoImage = imfinfo(filename);
        NumberImages=length(InfoImage);

        f_matrix = zeros(InfoImage(1).Height,InfoImage(1).Width,NumberImages,'uint16');
        for i=1:NumberImages
            f_matrix(:,:,i) = imread(filename,'Index',i,'Info',InfoImage);
        end
        
        f_matrix = double(reshape(f_matrix,InfoImage(1).Height*InfoImage(1).Width,NumberImages));
        
        for roi_idx=1:numel(roi_list)
            current_mask = zeros(1,InfoImage(1).Height*InfoImage(1).Width);
            try
                current_mask(roi_list(roi_idx).pixel_idx) = 1;
            catch
                current_mask(roi_list(roi_idx).PixelIdxList) = 1;
            end
            current_trace = (current_mask*f_matrix)/sum(current_mask);
            roi_list(roi_idx).file(file_idx).filename = filename;
            roi_list(roi_idx).file(file_idx).trace = current_trace;
            
            if file_idx==1
                roi_list(roi_idx).trace = current_trace;
            else
                roi_list(roi_idx).trace = cat(2,roi_list(roi_idx).trace,current_trace);
            end
            
        end
        
    end
    
    for roi_idx=1:numel(roi_list)
        roi_list(roi_idx).color = rand(1,3);
    end
        
    save(['trace_',save_keyword],'roi_list');
    fprintf(['Total loading time: ',num2str(round(toc(whole_tic),2)),' seconds.\n']);
    
end