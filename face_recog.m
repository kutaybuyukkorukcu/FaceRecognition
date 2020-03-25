% Orjinal fotografi okuyup, ekranda gosteriyoruz.
fotograf = imread('fotograf.jpg');
figure; imshow(fotograf);

%  Fotograf RGB ise if kosulu icine giriyor.
if(size(fotograf, 3) > 1)
    % Fotografimiz uzerinde uygulayacagimiz filtreleme islemlerinin sonuclarini atayacagimiz bir matris yaratiyoruz.
    filtrelenmis_fotograf2 = zeros(size(fotograf, 1), size(fotograf, 2));
    % size(fotograf, 1) ve size(fotograf, 2) degerleri ile fotografin en ve boy degerlerini alip for dongusunu baslatiyoruz.
    for i = 1:size(fotograf,1)
        for j = 1:size(fotograf,2)
            R = fotograf(i,j,1);
            G = fotograf(i,j,2);
            B = fotograf(i,j,3);

            % Fotografin her bir pikselinin RGB degerleri goz onune alinarak ten rengi degerleri uzerinden kosul uyguluyoruz.
            % Boylece fotografin yeni halinde ten rengi beyaz olup fotograftaki diger renklerin siyah olmasini sagliyoruz.
            if(R > 95 && G > 40 && B > 20)
                v = [R G B];
                if((max(v) - min(v)) > 15)
                    if(abs(R-G) > 15 && R > G && R > B)
                        % Yukarida zeros fonksiyonu kullanarak olusturdugumuz matrise eger piksel RGB ten rengi araliginda degilse ellemiyoruz (zaten matris 0'lardan olusuyor, atama yapmama gerek yok)
                        % RGB ten rengi araliginda ise 1 olacak sekilde matrise atama yapiyoruz.
                        filtrelenmis_fotograf2(i,j) = 1;
                    end
                end
            end
        end
    end
end 

filtrelenmis_fotograf1 = im2bw(filtrelenmis_fotograf2);
% Fotografi siyah-beyaz donusturdukten sonra beyaz alanlarin icerisinde kucuk siyah noktalarin kalmamasi adina imfill() kullanarak doldurma islemi gerceklestiriyoruz.
filtrelenmis_fotograf = imfill(filtrelenmis_fotograf1, 'holes');
figure,imshow(filtrelenmis_fotograf);title('siyah-beyaz');
figure,imshow(filtrelenmis_fotograf);

% Bulunan yüzlerin koordinat değerlerini yuzlerin_koordinati şeklinde bir matris olarak alıyoruz.
yuzlerin_koordinati = YuzBulma('fotograf.jpg');

% Yuzlerin bulundugu matris ornegin
% [ a b c d
%   e f g h
%   k l m n ] donuyor. M ve N'ye matrisin ileride kullanmak adina boyutlarini atiyoruz.
[M, N] = size(yuzlerin_koordinati);
yuz_koordinati = zeros(1, 4);
z = 1;

% Fotografta bulunan beyaz alan ve sekillerin merkez koordinatlarini donmesi icin regionprops kullaniyoruz.
s = regionprops(filtrelenmis_fotograf, 'BoundingBox');

% Fotografin ilk orjinal halini okuyup, hold on sayesinde cerceveleme islemlerinin orjinal fotograf uzerinde yapilmasini sagliyoruz. 
imshow(fotograf);
hold on;

% M bana fotografta kac tane yuz buldugunu gsteriyor. 
% Her yuzun koordinati icin asagidaki islemleri gerceklestiriyoruz.
for x = 1:M 
    % q tanimliyoruz, boylece onceden tanimlamis oldugumuz yuz_koordinati matrisine tek yuzun koordinati atayabilelim.
    q = 1;
    
    % Yukarida kullandigimiz yuz tanima fonksiyonu bize her yuz icin 4 deger donuyor.
    % Ornegin fotografta 3 tane yuz tanimis ise 
    % [ a b c d
    %   e f g h
    %   k l m n ] donuyor.
    % a yuzun sol ustunun x koordinatini, b yuzun sol ustunun y koordinatini
    % c yuzun soldan saga buyuklugunu, d ise yuzun yukaridan asagi buyuklugunu barindiriyor.
    % a b c d bir yuzun koordinati, e f g h ikinci yuzun koordinati, k l m n ucuncu yuzun koordinati

    % Asagidaki for dongusu ile yukari gibi bir matristen ilk 4 degeri diger programlama dillerinde oldugu gibi alamadigimizdan 
    % z:M:M*N sayesinde 1,3,5,7 ile ilk yuz koordinatlarini aliyoruz.
    % Ikinci yuz icin asagida z'ye +1 ekledigimizden dolayi 2,4,6,8 ile 2. yuzu aliyoruz... 
    for i = z:M:M*N
        yuz_koordinati(q) = yuzlerin_koordinati(i);
        q = q + 1;
    end

    yuzun_yarisi_en = yuz_koordinati(3) / 2;
    yuzun_yarisi_boy = yuz_koordinati(4) / 4;

    % Fotografta bulunan yuzun asagidaki islemleri ile merkez koordinatlarini buluyoruz.
    yuz_merkez_x = (yuz_koordinati(1) + (yuz_koordinati(1) + yuz_koordinati(3))) / 2;
    yuz_merkez_y = (yuz_koordinati(2) + (yuz_koordinati(2) + yuz_koordinati(4))) / 2;
    
    for k = 1:length(s)
     boundary = s(k).BoundingBox;
     % BBOX'daki matrisler gibi boundary de ayni karakteristik ozellikle matris barindirir.
     sekil_x = boundary(1);
     sekil_y = boundary(2);
     sekil_en = boundary(3);
     sekil_boy = boundary(4);
     
     % Fotograftaki herhangi bir beyaz seklin asagidaki islemleri ile merkez koordinatlarini buluyoruz.
     sekil_merkez_x = (sekil_x + (sekil_x + sekil_en)) / 2;
     sekil_merkez_y = (sekil_y + (sekil_y + sekil_boy)) / 2;

        if (((yuz_merkez_x + yuzun_yarisi_boy) > sekil_merkez_x && sekil_merkez_x > (yuz_merkez_x - yuzun_yarisi_boy)) && ((yuz_merkez_y + yuzun_yarisi_boy) > sekil_merkez_y && sekil_merkez_y > (yuz_merkez_y - yuzun_yarisi_boy)))   
          % fake_x'den yuzun_yarisi / 2 cikarirken, fake_y'den yuzun_yarisi'ni cikarmamizin sebebi genellikle yuzu cevreleyen cercevenin boy = 3/2 * en oranina yakin olmasindan dolayi.
          rectangle('Position',[(sekil_merkez_x - (yuzun_yarisi_en)) (sekil_merkez_y - (yuzun_yarisi_boy*2)) sekil_en sekil_boy],'EdgeColor','r','LineWidth',2);
        end
    end
    z = z + 1;
end

sayac = sayac + 1;
s1 = int2str(sayac);
s2 = ' yuz bulundu';
s = strcat(s1, s2);
title(s);
