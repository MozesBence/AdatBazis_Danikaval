--2--Összetett lekérdezés, ahol az allekérdezés, mint érték szerepeljen

--Add meg az első diák nevét akinek mind a 3 pont nem elfogadott (ervenyes, elfogadva, teljesitve = False)   --KÉSZ--

select d.nev
from diak d
where d.id =(select j.diakid
                    from jelentkezes j
                    where j.elfogadva = "False" and j.ervenyes = "False" and j.teljesitve = "False"
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
--Írasd ki melyik diáknak volt a legkevesebb érvényes munkája,ahol allekérdezés ,ami egy tábla, segítségével fogsz dolgozni.  --KJÉSZ--
SELECT d.nev
from diak d,
(SELECT j.diakid as azon
	FROM jelentkezes j
 	WHERE j.ervenyes = "True"
    group by j.diakid
    order BY Count(j.diakid) desc
	limit 1
) j
where d.id = j.azon

--10--Egyszerű csoportosító lekérdezés + aggregátum függvények + INNER JOIN kapcsolattal, csoportosítás utáni feltétellel
--IRASD KI MEIK ISKOLAI közösség munkának van/volt több mint 50 diák munkása --KÉSZ--
select t.nev, Count(d.id) as diakszam
from tevekenyseg t 
    inner join munka m on m.tevekenysegid = t.id
    inner join jelentkezes j on j.munkaid = m.id
    inner join diak d on d.id = j.diakid
where t.iskolai ="True"
group by t.id
having diakszam>50

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

