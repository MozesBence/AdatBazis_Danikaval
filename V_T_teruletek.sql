--2--Összetett lekérdezés, ahol az allekérdezés, mint érték szerepeljen

--Feladat addmeg azokat a védett területek nevét, amely a legnagyobb terület kategóriájával egyezőek

select vt.nev
from vt vt
where vt.kategoria ==(select vt.kategoria
                    from vt vt
                    order by vt.terulet
                    limit 1)




--4--Összetett lekérdezés, ahol az allekérdezés egy listával tér vissza: IN

--irasd ki minden igazgaosag nevet ami szerepel a védett területek között --> beszúrt 1 value nem jelenik meg
SELECT ig.nev
FROM igazgatosag ig
WHERE ig.id in (select vt.igid
                from vt vt )
                    
--6--Összetett lekérdezés, ahol a „minden” feltételt után kerül az allekérdezés (ALL)

--irasd ki minden telepulesnek a nevét, amelynek minden védett terület azonosítója nagyobb száznál

SELECT t.nev
FROM telepules t
WHERE <all(select k.telepid
            from kapcsolo k
            where k.vtid>=100)

--8--Összetett lekérdezés, ahol az allekérdezés, mint tábla fog szerepelni


--10--Egyszerű csoportosító lekérdezés + aggregátum függvények + INNER JOIN kapcsolattal, csoportosítás utáni feltétellel
SELECT t.nev, m.darab
FROM targy t inner join (SELECT t.kategoria as kat ,count(j.id) as darab
						FROM targy t inner join jegy j on t.id = j.targyid
						group by t.kategoria
						order by darab								--itt nem tom mit jelenthet a csop után szov rá kell kérdezni.
						limit 1) m on t.kategoria = m.kat

--12--Választó lekérdezés LEFT JOIN kapcsolattal + csoportsítás
select f.cim
from ((vendeg v inner join jegy j on v.id = j.vendegId)
				inner join vetites vet on vet.id =j.vetitesId)
				right join film f on f.id = vet.filmId
where v.nev = "Antal Bendegúz"
group by f.cim				--ennél tudunk könnyebbet :,I  csak erre találtam group by osat

--14--Választó lekérdezés LEFT JOIN kapcsolattal + minden adat az egyik táblából

--???

