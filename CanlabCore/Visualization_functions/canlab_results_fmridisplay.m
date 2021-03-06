function o2 = canlab_results_fmridisplay(input_activation, varargin)

% usage: function canlab_results_fmridisplay(input_activation, [optional inputs])
% Tor Wager
% 1/27/2012
% purpose:  This function display fmri results.
%
% input:    input_activation - nii, img,
%           This image has the blobs you want to
%           display. You can also enter a cl "clusters" structure or
%           "region" object.
%
%           you can also get a thresholded image like the examples used here
%           from a number of places - by thresholding your results in SPM
%           and using "write filtered" to save the image, by creating masks
%           from meta-analysis or anatomical atlases, or by using
%           mediation_brain_results, robust_results_threshold,
%           robust_results_batch_script, threshold_imgs, or object
%           oriented tools including fmri_data and statistic_image objects.
%
% optional inputs:
% -------------------------------------------------------------------------
% 'noblobs' : do not display blobs
% 'nooutline' : do not display blob outlines
% 'addmontages' : when entering existing fmridisplay obj, add new montages
% 'noremove' : do not remove current blobs when adding new ones
% 'outlinecolor : followed by new outline color
% 'splitcolor' : followed by 4-cell new split colormap colors (help fmridisplay or edit code for defaults as example)
%
% 'montagetype' : 'full' for full montages of axial and sagg slices.
%                 'compact' [default] for single-figure parasagittal and
%                 axials slices.
%                 'compact2': like 'compact', but fewer axial slices.
%
% 'noverbose' : suppress verbose output, good for scripts/publish to html, etc.
%
% * Other inputs to addblobs (fmridisplay method) are allowed, e.g., 'cmaprange', [-2 2], 'trans'
% See help fmridisplay
% e.g., 'color', [1 0 0]
%
% You can also input an existing fmridisplay object, and it will use the
% one you have created rather than setting up the canonical slices.
%
% example script:
% -------------------------------------------------------------------------
% input_activation = 'Pick_Atlas_PAL_large.nii';
%
% % set up the anatomical underlay and display blobs
% % (see the code of this function and help fmridisplay for more examples)
%
% o2 = canlab_results_fmridisplay(input_activation);
%
% %% ========== remove those blobs and change the color ==========
%
% cl = mask2clusters(input_activation);
% removeblobs(o2);
% o2 = addblobs(o2, cl, 'color', [0 0 1]);
%
% %% ========== OR
%
% r = region(input_activation);
% o2 = removeblobs(o2);
% o2 = addblobs(o2, r, 'color', [1 0 0]);
%
% %% ========== Create empty fmridisplay object on which to add blobs:
% o2 = canlab_results_fmridisplay
% o2 = canlab_results_fmridisplay([], 'compact2', 'noverbose');
%
% %% ========== If you want to start over with a new fmridisplay object,
% % make sure to clear o2, because it uses lots of memory
%
% % This image should be on your path in the "canlab_canonical_brains" subfolder:
%
% input_activation = 'pain-emotion_2s_z_val_FDR_05.img';
% clear o2
% close all
% o2 = canlab_results_fmridisplay(input_activation);
%
% %% ========== save PNGs of your images to insert into powerpoint, etc.
% % for your paper/presentation
%
% scn_export_papersetup(400);
% saveas(gcf, 'results_images/pain_meta_fmridisplay_example_sagittal.png');
%
% scn_export_papersetup(350);
% saveas(gcf, 'results_images/pain_meta_fmridisplay_example_sagittal.png');
%
% Change colors, removing old blobs and replacing with new ones:
% o2 = canlab_results_fmridisplay(d, o2, 'cmaprange', [.3 .45], 'splitcolor', {[0 0 1] [.3 0 .8] [.9 0 .5] [1 1 0]}, 'outlinecolor', [.5 0 .5]);


if ~which('fmridisplay.m')
    disp('fmridisplay is not on path.  it is in canlab tools, which must be on your path!')
    return
end

if nargin == 0
    o2 = canlab_results_fmridisplay(region(), 'noblobs', 'nooutline');
    return
end

if ischar(input_activation)
    cl = mask2clusters(input_activation);
    
elseif isstruct(input_activation) || isa(input_activation, 'region')
    cl = input_activation;
    
elseif isa(input_activation, 'image_vector')
    cl = region(input_activation);
    
elseif isempty(input_activation)
    % do nothing for now
    
else
    error('I don''t recognize the format of input_activation.  It should be a thresholded mask, clusters, or region object');
end

% process input arguments
% --------------------------------------------
doblobs = true;
dooutline = true;
doaddmontages = false;
doremove = true;
outlinecolor = [0 0 0];
splitcolor = {[0 0 1] [.3 0 .8] [.8 .3 0] [1 1 0]};
montagetype = 'compact';
doverbose = true;

wh = strcmp(varargin, 'noblobs');
if any(wh), doblobs = false; varargin(wh) = []; end

wh = strcmp(varargin, 'nooutline');
if any(wh), dooutline = false; varargin(wh) = []; end

wh = strcmp(varargin, 'addmontages');
if any(wh), doaddmontages = true; varargin(wh) = []; end

wh = strcmp(varargin, 'outlinecolor');
if any(wh), wh = find(wh); outlinecolor = varargin{wh(1) + 1}; end

wh = strcmp(varargin, 'splitcolor');
if any(wh), wh = find(wh); splitcolor = varargin{wh(1) + 1}; end

wh = strcmp(varargin, 'noremove');
if any(wh), doremove = false; varargin(wh) = []; end

wh = strcmp(varargin, 'full');
if any(wh), montagetype = varargin{find(wh)}; varargin(wh) = []; end

wh = strcmp(varargin, 'compact');
if any(wh), montagetype = varargin{find(wh)}; varargin(wh) = []; end

wh = strcmp(varargin, 'compact2');
if any(wh), montagetype = varargin{find(wh)}; varargin(wh) = []; end

wh = strcmp(varargin, 'noverbose');
if any(wh), doverbose = false; varargin(wh) = []; end

wh = false(1, length(varargin));
for i = 1:length(varargin)
    wh(i) = isa(varargin{i}, 'fmridisplay');
    if wh(i), o2 = varargin{wh}; end
end
varargin(wh) = [];

xyz = [-20 -10 -6 -2 0 2 6 10 20]';
xyz(:, 2:3) = 0;

if isempty(input_activation)
    % we will skip the blobs, but process other optional input args
    doblobs = false;
    dooutline = false;
end



if ~exist('o2', 'var')
    
    % set up fmridisplay
    % --------------------------------------------
    % you only need to do this once
    % then you can add montages, add and remove blobs, add and remove points (for
    % meta-analysis), etc.
    
    if doverbose
        
        disp('Setting up fmridisplay objects');
        disp('This takes a lot of memory, and can hang if you have too little.');
        
    end
    
    o2 = fmridisplay;
    
    % You can customize these and run them from the command line
    
    switch montagetype
        case 'full'
            o2 = montage(o2, 'saggital', 'wh_slice', xyz, 'onerow', 'noverbose');
            %o2 = montage(o2, 'axial', 'slice_range', [-40 50], 'onerow', 'spacing', 8, 'noverbose');
            o2 = montage(o2, 'axial', 'slice_range', [-40 50], 'onerow', 'spacing', 8, 'noverbose', 'new_row', [-44 50 8]);

            % shift all axes down and left
            allaxh = findobj(gcf, 'Type', 'axes');
            for i = 1:length(allaxh)
                pos1 = get(allaxh(i), 'Position');
                pos1(2) = pos1(2) - 0.18;
                pos1(1) = pos1(1) - 0.03;
                set(allaxh(i), 'Position', pos1);
            end
            
            % Right lateral
            axh = axes('Position', [0.15 0.28 .15 1]);
            rl = addbrain('hires right');
            set(rl, 'FaceColor', [.5 .5 .5], 'FaceAlpha', 1);
            view(90, 0);
            lightRestoreSingle; axis image; axis off; lighting gouraud; material dull
            
            % Right medial
            axh = axes('Position', [0.35 0.29 .15 1]);
            copyobj(rl, axh);
            view(270, 0);
            lightRestoreSingle; axis image; axis off; lighting gouraud; material dull
            
            % Left lateral
            axh = axes('Position', [0.55 0.3 .15 1]);
            ll = addbrain('hires left');
            set(ll, 'FaceColor', [.5 .5 .5], 'FaceAlpha', 1);
            view(270, 0);
            lightRestoreSingle; axis image; axis off; lighting gouraud; material dull
            
            % Left medial
            axh = axes('Position', [0.75 0.3 .15 1]);
            copyobj(ll, axh);
            view(90, 0);
            lightRestoreSingle; axis image; axis off; lighting gouraud; material dull
            
            
        case 'compact'
            o2 = montage(o2, 'axial', 'slice_range', [-40 50], 'onerow', 'spacing', 6, 'noverbose');
            axh = axes('Position', [0.05 0.4 .1 .5]);
            o2 = montage(o2, 'saggital', 'wh_slice', [0 0 0], 'existing_axes', axh, 'noverbose');
            
        case 'compact2'
            %subplot(2, 1, 1);
            o2 = montage(o2, 'axial', 'slice_range', [-32 50], 'onerow', 'spacing', 8, 'noverbose');
            %o2 = montage(o2, 'axial', 'slice_range', [-40 50], 'onerow', 'spacing', 8, 'noverbose', 'new_row', [-44 50 8]);

             % shift all axes down and right
            allaxh = o2.montage{1}.axis_handles;
            for i = 1:length(allaxh)
                pos1 = get(allaxh(i), 'Position');
                 pos1(2) = pos1(2) - 0.08;
                pos1(1) = pos1(1) + 0.03;
                set(allaxh(i), 'Position', pos1);
            end
            
            enlarge_axes(gcf, 1);
            axh = axes('Position', [0.0 0.08 .15 1]);
            o2 = montage(o2, 'saggital', 'wh_slice', [0 0 0], 'existing_axes', axh, 'noverbose');
                        
            %axh1 = axes('Position', [-0.03 -0.1 .2 1]);
            %subplot(2, 1, 2);
            %o2 = montage(o2, 'axial', 'slice_range', [-44 50], 'onerow', 'spacing', 8, 'noverbose');
            
            
            %ss = get(0, 'ScreenSize');
            %set(gcf, 'Position', [round(ss(3)/12) round(ss(4)*.9) round(ss(3)*.8) round(ss(4)/5.5) ]) % this line messes p the
            %images, makes it too big an overlapping
            
        otherwise error('illegal montage type. choose full or compact.');
    end
    
    wh_montages = [1 2];
    
    
else
    if doverbose, disp('Using existing fmridisplay object'); end
    
    % Other inputs will be passed into addblobs
    existingmons = length(o2.montage);
    
    if doaddmontages
        % use same o2, but add montages
        switch montagetype
            case 'full'
                o2 = montage(o2, 'saggital', 'wh_slice', xyz, 'onerow', 'noverbose');
                o2 = montage(o2, 'axial', 'slice_range', [-40 50], 'onerow', 'spacing', 6, 'noverbose');
                
            case 'compact'
                o2 = montage(o2, 'axial', 'slice_range', [-40 50], 'onerow', 'spacing', 6, 'noverbose');
                axh = axes('Position', [0.05 0.4 .1 .5]);
                o2 = montage(o2, 'saggital', 'wh_slice', [0 0 0], 'existing_axes', axh, 'noverbose');
                
            case 'compact2'
                o2 = montage(o2, 'axial', 'slice_range', [-40 50], 'onerow', 'spacing', 8, 'noverbose');
                enlarge_axes(gcf, 1);
                axh = axes('Position', [-0.03 0.15 .2 1]);
                o2 = montage(o2, 'saggital', 'wh_slice', [0 0 0], 'existing_axes', axh, 'noverbose');
                
                % shift all axes down and right
                allaxh = findobj(gcf, 'Type', 'axes');
                for i = 1:length(allaxh)
                    pos1 = get(allaxh(i), 'Position');
                    pos1(2) = pos1(2) - 0.10;
                    pos1(1) = pos1(1) + 0.03;
                    set(allaxh(i), 'Position', pos1);
                end
                
                %ss = get(0, 'ScreenSize');
                %set(gcf, 'Position', [round(ss(3)/12) round(ss(4)*.9) round(ss(3)*.8) round(ss(4)/5.5) ])
                
                
            otherwise error('illegal montage type. choose full or compact.')
        end
        
        wh_montages = existingmons + [1 2];
        
    else
        if doremove
            o2 = removeblobs(o2);
        end
        wh_montages = 1:existingmons;
        
    end
    
end

% Now we can add blobs
% --------------------------------------------

% they are added to all montages by default, but you can specify selected
% montages if you want to as well.

% it's easy to remove them as well:
% o2 = removeblobs(o2);

if doblobs
    o2 = addblobs(o2, cl, 'splitcolor', splitcolor, 'wh_montages', wh_montages, varargin{:});
end

if dooutline
    o2 = addblobs(o2, cl, 'color', outlinecolor, 'outline', 'wh_montages', wh_montages);
end


end  % function
