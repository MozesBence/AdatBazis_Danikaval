--2--Összetett lekérdezés, ahol az allekérdezés, mint érték szerepeljen

--Add meg azoknak a diákoknak a nevét akik ugyanabba az osztályyba járnak mint a legelső azonosítójú  diák  --KÉSZ--
--(Ő is kerüljön bele)

select d.nev
from diak d
where d.osztaly =(select d.osztaly
                    from diak d
                    limit 1)




--4--Összetett lekérdezés, ahol az allekérdezés egy listával tér vissza: IN

--irasd ki minden igazgaosag nevet ami szerepel a védett területek között --> beszúrt 1 value nem jelenik meg  --KÉSZ--
SELECT d.nev
FROM diak d
WHERE d.id in (select j.diakid
                from jelentkezes j )
                    
--6--Összetett lekérdezés, ahol a „minden” feltételt után kerül az allekérdezés (ALL)

--irasd ki az összes munka azonosítóját ami rövidebb minden 3 maxlétszámú munkánál  --KÉSZ--

SELECT m.id
FROM munka m
WHERE m.hossz<all(select m.hossz
            from munka m
            where m.maxletszam=3)

--8--Összetett lekérdezés, ahol az allekérdezés, mint tábla fog szerepelni
--??

--10--Egyszerű csoportosító lekérdezés + aggregátum függvények + INNER JOIN kapcsolattal, csoportosítás utáni feltétellel
SELECT t.nev, m.darab
FROM targy t inner join (SELECT t.kategoria as kat ,count(j.id) as darab
						FROM targy t inner join jegy j on t.id = j.targyid
						group by t.kategoria
						order by darab								--itt nem tom mit jelenthet a csop után szov rá kell kérdezni.
						limit 1) m on t.kategoria = m.kat

--12--Választó lekérdezés LEFT JOIN kapcsolattal + csoportsítás  --KÉSZ--
--Írasd ki mennyien teljesítettek egyes munkahosszban

select Count(j.teljesitve),m.hossz
from jelentkezes j LEFT join munka m on j.munkaid = m.id
group by m.hossz



--14--Választó lekérdezés LEFT JOIN kapcsolattal + minden adat az egyik táblából --KÉSZ--
--Írassuk ki azokat a munkákat ahol Pék Roland iskolai tevékenységekben dolgozott

select m.id
from jelentkezes j left join munka m on j.munkaid = m.id, diak d, tevekenyseg t
where d.id=j.diakid and m.tevekenysegid=t.id and d.nev = "Pék Roland" and t.iskolai="True"

