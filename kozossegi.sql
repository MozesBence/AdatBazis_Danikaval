-- 1. Szúrja be saját magát a diák táblába.- 
-- Új mező, auto increment nélkül
insert into diak values((SELECT max(d.id)+1
						 FROM diak d),"Mózes Bence","11/C")
--2--Összetett lekérdezés, ahol az allekérdezés, mint érték szerepeljen
--Add meg azoknak a diákoknak a nevét akik ugyanabba az osztályyba járnak mint a legelső azonosítójú  diák  
--(Ő is kerüljön bele)
select d.nev
from diak d
where d.osztaly =(select d.osztaly
                    from diak d
                    limit 1)
--3.--Összetett lekérdezés, ahol az allekérdezés, mint érték szerepeljen (többszörösen összetett – legalább két allekérdezés)
--Adja meg azokat a tevékenységeket és a tevékenységeket végző diákok nevét amit azok végeztek akik ugyanabba az osztályba járnak mint Oláh Soma és a tevékenység max létszáma egyenlő az első fordító munka időtartamával.
select distinct d.nev,t.nev
from diak d,munka m,jelentkezes j,tevekenyseg t
where d.id=j.diakid and j.munkaid=m.id and m.tevekenysegid=t.id and d.osztaly =(select d.osztaly
																			from diak d
																			where d.nev="Oláh Soma") and m.maxletszam = (select m.hossz
																											from tevekenyseg t,munka m																										where m.tevekenysegid=t.id and t.nev="fordítás"
																											limit 1)
--4--Összetett lekérdezés, ahol az allekérdezés egy listával tér vissza: IN
--irasd ki minden igazgaosag nevet ami szerepel a védett területek között --> beszúrt 1 value nem jelenik meg  
SELECT d.nev
FROM diak d
WHERE d.id in (select j.diakid
                from jelentkezes j )
                    
--5.--Összetett lekérdezés, ahol az allekérdezés egy listával tér vissza: NOT IN
--Add meg azokanak a diákoknak a nevét akik keresztneve D betűvel kezdődik és nem 10. évfolyamosok

select d.nev,--d.osztaly --KÉSZ
from diak d
where d.nev like "D%" and d.nev not in (select d.osztaly 
                                  from diak d
                                  where d.osztaly like "10%")
--6--Összetett lekérdezés, ahol a „minden” feltételt után kerül az allekérdezés (ALL)
--irasd ki az összes munka azonosítóját ami rövidebb minden 3 maxlétszámú munkánál  

SELECT m.id
FROM munka m
WHERE m.hossz<all(select m.hossz
            from munka m
            where m.maxletszam=3)
--7--Összetett lekérdezés, ahol a „bármelyik” feltételt után kerül az allekérdezés (ANY)
--Add meg azokat a tevékenységeket ha van amit úgy végeztek el hogy a maxlétszáma nagyobb mint bármelyik 11.-edikes évfolyamből elvégzett munka maxlétszáma																																	
select distinct m.tevekenysegid
from tevekenyseg t,munka m
where t.id=m.tevekenysegid and m.maxletszam>any(select m.maxletszam
												from diak d,munka m,jelentkezes j,tevekenyseg t
												where d.id=j.diakid and j.munkaid=m.id and m.tevekenysegid=t.id and m.maxletszam=10 and t.iskolai="True")
--8--Összetett lekérdezés, ahol az allekérdezés, mint tábla fog szerepelni
--Írasd ki melyik diáknak volt a legkevesebb érvényes munkája,ahol allekérdezés ,ami egy tábla, segítségével fogsz dolgozni.  
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
--9 Egyszerű csoportosító lekérdezés + aggregátum függvények + INNER JOIN kapcsolattal, csoportosítás előtti feltétellel
--Írasd azoknak a tevékenységeknek az átlagát (órahossz),amelyek az iskolához köthetőek
select avg(m.hossz),t.nev
from tevekenyseg t 
    inner join munka m on m.tevekenysegid = t.id
    inner join jelentkezes j on j.munkaid = m.id
    inner join diak d on d.id = j.diakid
where t.iskolai="True" 
group by m.tevekenysegid
--10--Egyszerű csoportosító lekérdezés + aggregátum függvények + INNER JOIN kapcsolattal, csoportosítás utáni feltétellel
--IRASD KI MEIK ISKOLAI közösség munkának van/volt több mint 50 diák munkása 
select t.nev, Count(d.id) as diakszam
from tevekenyseg t 
    inner join munka m on m.tevekenysegid = t.id
    inner join jelentkezes j on j.munkaid = m.id
    inner join diak d on d.id = j.diakid
where t.iskolai ="True"
group by t.id
having diakszam>50
--11--Választó lekérdezés LEFT JOIN kapcsolattal + csak az egyik tábla adatai
--Írja ki azokat a diákokat akik még nem jelentkeztek diákmunkára.
select d.nev
from diak d left join jelentkezes j on j.diakid=d.id
where j.diakid is null
--12--Választó lekérdezés LEFT JOIN kapcsolattal + csoportsítás  
--Írasd ki mennyien teljesítettek egyes munkahosszban
select Count(j.teljesitve),m.hossz
from jelentkezes j LEFT join munka m on j.munkaid = m.id
group by m.hossz
--13--Választó lekérdezés LEFT JOIN kapcsolattal + több táblával --Ide kell 
--Írasd ki az osztályok által elvégzett órák hosszát azokból a tevékenységekből amelyeket nem az iskolában végzett
select d.osztaly,t.nev,sum(m.hossz)
from diak d left join jelentkezes j on d.id=j.diakid
	left join munka m on j.munkaid=m.id
	left join tevekenyseg t on m.tevekenysegid=t.id
where t.iskolai="False"
group by d.osztaly
--14--Választó lekérdezés LEFT JOIN kapcsolattal + minden adat az egyik táblából 
--Írassuk ki azokat a munkákat ahol Pék Roland iskolai tevékenységekben dolgozott
select m.id
from jelentkezes j left join munka m on j.munkaid = m.id, diak d, tevekenyseg t
where d.id=j.diakid and m.tevekenysegid=t.id and d.nev = "Pék Roland" and t.iskolai="True"
--15.--Összetett lekérdezés UNION (Full Outer Join) segítségével.
--Írja ki azokat a diákokat,akik Oláh Soma osztálytársai és nem jelentkeztek munkára.
select d.nev
from diak d
where d.osztaly=(select d.osztaly
				from diak d
				where d.nev="Oláh Soma")
				
union

select d.nev
from diak d left join jelentkezes j on j.diakid=d.id
where j.diakid is null
