clc
clear all
close all
warning off
[filename, pathname] = uigetfile({'.jpg';'.png';'*.bmp'}, 'Select Carrier File');
a = imread(fullfile(pathname, filename));
subplot(3,2,1);
imshow(a);
title('Carrier Image');

[filename, pathname] = uigetfile({'.jpg';'.png';'*.bmp'}, 'Select Secret File');
x = imread(fullfile(pathname, filename));
subplot(3,2,2)
imshow(x);
title('Secret Image');



[r c g]=size(a);
x=imresize(x,[r c]);
ra=a(:,:,1);
ga=a(:,:,2);
ba=a(:,:,3);
rx=x(:,:,1);
gx=x(:,:,2);
bx=x(:,:,3);
sk=uint8(rand(r,c)*255);%Secret key
rx=bitxor(rx,sk);
gx=bitxor(gx,sk);
bx=bitxor(bx,sk);
subplot(3,2,3);
imshow(cat(3,rx,gx,bx));
title('Encrypted Secret Message');



for i=1:r
    for j=1:c
       nc(i,j)= bitand(ra(i,j),254);
       ns(i,j)= bitand(rx(i,j),128);
       ds(i,j)=ns(i,j)/128;
       fr(i,j)=nc(i,j)+ds(i,j);
    end
end
redsteg=fr;
for i=1:r
    for j=1:c
       nc(i,j)= bitand(ga(i,j),254);
       ns(i,j)= bitand(gx(i,j),128);
       ds(i,j)=ns(i,j)/128;
       fr(i,j)=nc(i,j)+ds(i,j);
    end
end
greensteg=fr;
for i=1:r
    for j=1:c
       nc(i,j)= bitand(ba(i,j),254);
       ns(i,j)= bitand(bx(i,j),128);
       ds(i,j)=ns(i,j)/128;
       fr(i,j)=nc(i,j)+ds(i,j);
    end
end
bluesteg=fr;
finalsteg=cat(3,redsteg,greensteg,bluesteg);
redstegr=finalsteg(:,:,1);
greenstegr=finalsteg(:,:,2);
bluestegr=finalsteg(:,:,3);
subplot(3,2,4);
imshow(finalsteg);
title('Stegmented Image');


for i=1:r
    for j=1:c
        nc(i,j)=bitand(redstegr(i,j),1);
        ms(i,j)=nc(i,j)*128;
    end
end
recoveredr=ms;
for i=1:r
    for j=1:c
        nc(i,j)=bitand(greenstegr(i,j),1);
        ms(i,j)=nc(i,j)*128;
    end
end
recoveredg=ms;
for i=1:r
    for j=1:c
        nc(i,j)=bitand(bluestegr(i,j),1);
        ms(i,j)=nc(i,j)*128;
    end
end
recoveredb=ms;
output=cat(3,recoveredr,recoveredg,recoveredb);
subplot(3,2,5);
imshow(output);
title('Recovered Encrypted Image');
red_band=bitxor(output(:,:,1),sk);
green_band=bitxor(output(:,:,2),sk);
blue_band=bitxor(output(:,:,3),sk);
combined=cat(3,red_band,green_band,blue_band);
% Enhance colors using histogram equalization
img_enhanced = histeq(combined);

% Sharpen the image using unsharp masking
img_sharpened = imsharpen(img_enhanced, 'Amount', 0.5);

% Smooth the image using a Gaussian filter
img_smoothed = imgaussfilt(img_sharpened, 2);  % Adjust sigma for desired smoothness

subplot(3,2,6);
imshow(img_smoothed);
title('Decrypted secret message signal');


% For Histogram
show_histograms = questdlg('Do you want to display histograms?', ...
    'Histogram Option', 'Yes', 'No', 'No');

if strcmpi(show_histograms, 'Yes')
    [counts, bins] = imhist(a);
    figure;  % Create a new figure window for the first histogram
    bar(bins, counts);
    title('Carrier Image Histogram');
    xlabel('Intensity Values');
    ylabel('Frequency');

    [count, bin] = imhist(finalsteg);
    figure;  % Create a new figure window for the second histogram
    bar(bin, count);
    title('Stegmented Image Histogram');
    xlabel('Intensity Values');
    ylabel('Frequency');
end


% Prompt for saving options
choice = questdlg('Save output images as a ZIP file or in a folder?', ...
    'Save Options', 'ZIP File', 'Folder', 'Folder');

if strcmpi(choice, 'ZIP File')
    % Get a filename for the ZIP file (will be used later)
    [filename, pathname] = uiputfile({'*.zip'}, 'Specify ZIP filename');
    if filename ~= 0
        full_filename = fullfile(pathname, filename);
        full_filename = char(full_filename);  % Ensure correct path format

        if isempty(pathname)  % Handle missing path
            full_filename = fullfile(pwd, filename);  % Use current directory
        end
    end

    % Always save images to a temporary folder first
    temp_folder_path = tempname;  % Create a temporary folder
    mkdir(temp_folder_path);  % Create the folder

    % Save images to the temporary folder
    imwrite(a, fullfile(temp_folder_path, '1original_image.jpg'));
    imwrite(x, fullfile(temp_folder_path, '2secret_data_image.jpg'));
    imwrite(cat(3,rx,gx,bx), fullfile(temp_folder_path, '3encrypted_secret_image.jpg'));
    imwrite(finalsteg, fullfile(temp_folder_path, '4combined_image.jpg'));
    imwrite(output, fullfile(temp_folder_path, '5extracted_encrypted_image.jpg'));
    imwrite(img_smoothed, fullfile(temp_folder_path, '6smoothed_secret_image.jpg'));

    % Create the ZIP file from the temporary folder
    zip(full_filename, temp_folder_path);

    % Delete the temporary folder
    rmdir(temp_folder_path, 's');  % Delete recursively
else
    % Prompt for a regular folder location (no ZIP creation)
    folder_path = uigetdir('Select folder to save output images');
    if folder_path ~= 0
        % Save images to the specified folder with descriptive names
        imwrite(a, fullfile(folder_path, '1original_image.jpg'));
        imwrite(x, fullfile(folder_path, '2secret_data_image.jpg'));
        imwrite(cat(3,rx,gx,bx), fullfile(folder_path, '3encrypted_secret_image.jpg'));
        imwrite(finalsteg, fullfile(folder_path, '4combined_image.jpg'));
        imwrite(output, fullfile(folder_path, '5extracted_encrypted_image.jpg'));
        imwrite(img_smoothed, fullfile(folder_path, '6smoothed_secret_image.jpg'));
    else
        disp('No folder selected. Images will not be saved.');
    end
end