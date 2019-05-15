clear
image = imread('forged2_gj90.png'); %resim okundu

grayimage = rgb2gray(image); %resim gri seviyeye getirildi

doubleimage = double(grayimage); %resim double hale d�n��t�r�ld�

%Boyut degiskenleri
image_size = size(doubleimage);
row_size = image_size(1);
col_size = image_size(2);

VECTORS_SIZE = (row_size - 7) * (col_size - 7); %Overlapping blok say�s�
VECTORS = zeros(VECTORS_SIZE,18); %Blok say�s� boyutunda vekt�r olusturuldu

index = 1;

[row col]=size(doubleimage);
 for i=1:row-7
    for j=1:col-7
        BLOCK=doubleimage(i:i+7,j:j+7);%8x8 lik blok al�n�yor.
        dct2block = dct2(BLOCK); %Blo�a dct d�n���m uygulan�yor
        
        %ZigZag Scanning
        ind = reshape(1:numel(dct2block), size(dct2block));  %# indices of elements
        ind = fliplr( spdiags( fliplr(ind) ) );     %# get the anti-diagonals
        ind(:,1:2:end) = flipud( ind(:,1:2:end) );  %# reverse order of odd columns
        ind(ind==0) = [];   
        
        vector64 = dct2block(ind);%ZigZag tarama sonucu olusan de�erler vector64 degiskenine atan�yor.
        
        vector16 = vector64(1:16);%16 elemanl� vekt�r
        
        quantanized = floor(vector16 / 16); %Kuantalama yap�ld�
        
        extended_vector = quantanized; %Kuantalanm�� vekt�r yeni de�ere atand�
        extended_vector(17) = i; %X de�eri vekt�re eklendi
        extended_vector(18) = j; %Y de�eri vekt�re eklendi
        
        VECTORS(index,1:18) = extended_vector(1:18);
        index = index + 1;
    end
 end

 sorted_vectors = sortrows(VECTORS,(1:16)); %Lexicographic olarak vekt�rleri s�ral�yoruz.
 
 [vector_count col_count] = size(sorted_vectors);
 
 index = 1;
 eu = 0;
 
 for i=1:vector_count-11
    for j=i+1:i+10
        for k=1:col_count-2
            eu = power((sorted_vectors(j,k)-sorted_vectors(i,k)),2) + eu;
        end
        euclid_value = sqrt(eu);
        if euclid_value < 1.6
            distance = sqrt(power((sorted_vectors(j,17)-sorted_vectors(i,17)),2) + power((sorted_vectors(j,18)-sorted_vectors(i,18)),2));
            if distance > 115
                suspect_vectors(index,1:2) = sorted_vectors(i,17:18);
                suspect_vectors(index,3:4) = sorted_vectors(j,17:18);
                suspect_vectors(index,5) = abs(suspect_vectors(index,3)-suspect_vectors(index,1));
                suspect_vectors(index,6) = abs(suspect_vectors(index,4)-suspect_vectors(index,2));
                index = index + 1;
            end
        end
        eu = 0;%eu de�erini tekrar kullanmak i�in s�f�rla
    end
 end
 
sorted_suspects = sortrows(suspect_vectors,(5:6));%��pheli bloklar� 5.ve 6.s�tuna g�re s�rala

%��pheli bloklar� i�lemek i�in gerekli de�i�kenler tan�mlan�yor.
suspect_counter = 0;
index_row = 1;
 
 [sorted_row_size sorted_col_size] = size(sorted_suspects);
 for i=1:sorted_row_size
     for j=1:sorted_row_size
         if(sorted_suspects(i,5)==sorted_suspects(j,5) && sorted_suspects(i,6)==sorted_suspects(j,6))
                suspect_counter = suspect_counter + 1;
         end
     end
     if suspect_counter > 20
         current_row = sorted_suspects(i,1);
         current_col = sorted_suspects(i,2);
         suspect_row = sorted_suspects(i,3);
         suspect_col = sorted_suspects(i,4);
         image(current_row:current_row+7,current_col:current_col+7) = 255;
         image(suspect_row:suspect_row+7,suspect_col:suspect_col+7) = 255;
     end
     suspect_counter = 0;
 end
 
maske = imread('forged2_maske.png');
metrik = getFmeasure(maske,image);
imshow(image)
imshow(maske)
