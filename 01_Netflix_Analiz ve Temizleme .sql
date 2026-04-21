SELECT * FROM netflix_titles



-- NULL Değerleri bulma işlemi.
SELECT 'Eksik Ülke' AS Kategory , COUNT(*) AS Sayi FROM netflix_titles WHERE country  IS NULL UNION ALL
SELECT 'Eksik Yönetmen' , COUNT(*) FROM netflix_titles WHERE director IS NULL UNION ALL
SELECT 'Eksik rating' , COUNT(*) FROM netflix_titles WHERE rating IS NULL UNION ALL
SELECT 'Eksik oyuncu', COUNT(*) FROM netflix_titles WHERE cast IS NULL;



--VIEW ile sanal çalışma ortamı kurulumu. Null değerleri doldurma işlemi.
CREATE VIEW netflix_temiz AS
SELECT show_id, type,title,
ISNULL(director,'Unkown Director') AS director,
ISNULL(cast,'Unknown Cast') AS oyuncular,
ISNULL(country,'Unknown Country') AS şehirler,
ISNULL(rating,'Unknown rating') AS rating,
date_added,release_year,duration,listed_in,description
FROM netflix_titles

--Analiz işlemleri.
SELECT * FROM netflix_temiz


SELECT şehirler AS 'Ülke adı',COUNT(*) AS 'En çok içerik üreten ülke' FROM netflix_temiz 
GROUP BY şehirler ORDER BY 'En çok içerik üreten ülke' DESC
-- En çok içerik üreten ülke United States 2555 tane içerik üretildi.


SELECT YEAR(date_added) AS 'Ekleme_yılı' ,COUNT(*) AS 'İçeriklerin_toplamı' FROM netflix_temiz 
WHERE date_added IS NOT NULL 
GROUP BY YEAR(date_added) ORDER BY 'Ekleme_yılı' DESC;
-- 2018-2020 Yılları arasında (pandemi döneminde) içerik üretimi diğer yıllara göre daha fazla artmıştır.


SELECT TRIM(value) AS 'Tür', COUNT(*) AS 'Sayı' FROM netflix_temiz
CROSS APPLY STRING_SPLIT(listed_in,',')
GROUP BY TRIM(value)
ORDER BY Sayı DESC;
-- Film türleri arasında en çok izlenen Top 5.


SELECT YEAR(date_added) AS 'Yıl', COUNT(*) AS 'Toplam İçerik Sayısı' FROM netflix_temiz
CROSS APPLY STRING_SPLIT(listed_in,',') WHERE TRIM(value)='International Movies' AND date_added IS NOT NULL
GROUP BY YEAR(date_added)
ORDER BY Yıl DESC; 
-- 2017'den 2018 geçişte (pandemi) netflix 'yerel içerik (International Movies)' üretiminde bütçe artırmıştır.


SELECT TRIM(value) AS Tur,
    AVG(CASE 
        WHEN duration LIKE '%min%' THEN CAST(REPLACE(duration, ' min', '') AS INT)
        ELSE NULL 
    END) AS Ortalama_Dakika
FROM Netflix_Temiz
CROSS APPLY STRING_SPLIT(listed_in, ',')
WHERE duration LIKE '%min%' -- Sadece film olanları alıyoruz
GROUP BY TRIM(value)
ORDER BY Ortalama_Dakika DESC;
-- Filmlerin ortalama süreleri.


SELECT director,COUNT(show_id) AS 'Toplam İçerik Sayısı',
AVG(CASE
    WHEN duration LIKE '%min%' THEN CAST(REPLACE(duration,' min','') AS INT)
    ELSE NULL
   END) AS 'Ortalama_süre' FROM netflix_temiz
WHERE director != 'Unkown Director'
GROUP BY director
HAVING COUNT (show_id)>3
ORDER BY 'Toplam İçerik Sayısı' DESC;
--Yönetmenlerin üretim hacmi ile ortalama süre hacimleri kıyaslaması.

SELECT rating AS 'Yas Grubu',COUNT(*) AS 'İçerik Sayısı' from netflix_temiz
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY 'İçerik Sayısı' DESC;
-- İçerikleri izleyenlerin yaş grupları. Yetişkin/ Genç yetişkin ve Aile filmlerine yönelik yatırım yapılmaktadır.

SELECT şehirler, TRIM(value) AS 'Tür', COUNT(*) AS 'İçerik sayisi' FROM netflix_temiz
CROSS APPLY STRING_SPLIT(listed_in,',') WHERE şehirler IS NOT NULL AND şehirler != 'Unknown Country'
GROUP BY şehirler, TRIM(value)
HAVING COUNT(*)>50        -- Gürültü olmasın diye sınırlandırdık.
ORDER BY 'İçerik sayisi' DESC;

-- Netflix Global Çalışmaları En çok Hindistan ve US ülkelerine içerik üretmiştir. 