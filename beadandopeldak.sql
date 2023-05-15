
----Új mező beszúrása egy olyan táblába, ahol nincs auto_increment

INSERT INTO megnevezes VALUES((SELECT m.id
FROM megnevezes m
ORDER BY m.id DESC
limit 1)+1,"kátyú mélyítés")

--vagy
insert into vendeg values((select max(v.id)
							from vendeg v)+1,"Név")
							
----Összetett lekérdezés, ahol az allekérdezés, mint érték szerepeljen


								
--Összetett lekérdezés, ahol az allekérdezés, mint érték szerepeljen (többszörösen összetett – legalább két allekérdezés)
SELECT h.nev
from helyszin h
where h.megyeid in(SELECT m.id
					FROM helyszin h 
						inner join megye m on m.id= h.megyeid
						inner join torony t on t.helyszinid = h.id --csak inner joinosat találtam
					WHERE t.teljesitmeny =(SELECT max(t.teljesitmeny)
											from torony t))

--Összetett lekérdezés, ahol az allekérdezés egy listával tér vissza: IN

SELECT distinct sz.nev --hosszú tudunk könnyebbet írni sokkal, de most nem volt kedvem példába.
FROM szemely sz, fordito f, nyelv ny
WHERE sz.id = f.szemelyid and  f.nyelvid=ny.id and ny.cnyelv in (SELECT ny.cnyelv
					FROM szemely sz, fordito f, nyelv ny
					WHERE sz.id = f.szemelyid and  f.nyelvid=ny.id AND sz.nev = "Szőke Mátyás")

--Összetett lekérdezés, ahol az allekérdezés egy listával tér vissza: NOT IN
SELECT sz.nev
FROM szemely sz
WHERE sz.id not in(SELECT f.szemelyid
		FROM  fordito f)

--Összetett lekérdezés, ahol a „minden” feltételt után kerül az allekérdezés (ALL)
SELECT s.nev
FROM ar a, suti s
WHERE a.sutiid = s.id and
		s.tipus = "torta" and 
		a.ertek<all(SELECT a.ertek
					FROM tartalom t, ar a, suti s
					where a.sutiid = s.id and t.sutiid = s.id and t.mentes = "G" )

--Összetett lekérdezés, ahol a „bármelyik” feltételt után kerül az allekérdezés (ANY)
SELECT a.nev
FROM aru a
WHERE a.kat_kod != 5 AND a.ar<ANY(select a.ar
								FROM aru a
								WHERE a.kat_kod=5)

--Összetett lekérdezés, ahol az allekérdezés, mint tábla fog szerepelni
SELECT sz.nev
FROM szemely sz
WHERE sz.id not in(SELECT f.szemelyid
		FROM  fordito f)


--Egyszerű csoportosító lekérdezés + aggregátum függvények + INNER JOIN kapcsolattal, csoportosítás előtti feltétellel.
SELECT t.kategoria,count(j.id) as darab
FROM targy t inner join jegy j on t.id = j.targyid
group by t.kategoria																
order by darab
limit 1


--Egyszerű csoportosító lekérdezés + aggregátum függvények + INNER JOIN kapcsolattal, csoportosítás utáni feltétellel
SELECT t.nev, m.darab
FROM targy t inner join (SELECT t.kategoria as kat ,count(j.id) as darab
						FROM targy t inner join jegy j on t.id = j.targyid
						group by t.kategoria
						order by darab								--itt nem tom mit jelenthet a csop után szov rá kell kérdezni.
						limit 1) m on t.kategoria = m.kat

--Választó lekérdezés LEFT JOIN kapcsolattal + csak az egyik tábla adatai
SELECT m.nev
from megnevezes m left join korlatozas k on m.id=k.megnevid
where k.megnevid is NULL

--Választó lekérdezés LEFT JOIN kapcsolattal + csoportsítás
select f.cim
from ((vendeg v inner join jegy j on v.id = j.vendegId)
				inner join vetites vet on vet.id =j.vetitesId)
				right join film f on f.id = vet.filmId
where v.nev = "Antal Bendegúz"
group by f.cim				--ennél tudunk könnyebbet :,I  csak erre találtam group by osat

--Választó lekérdezés LEFT JOIN kapcsolattal + több táblával
select ny.nev
FROM kapcsolo k left join nyersanyag ny on k.nyersanyagid = ny.id 
				left join telek t on k.telekid =t.id
where t.telepules = "Vecsés"


--Választó lekérdezés LEFT JOIN kapcsolattal + minden adat az egyik táblából

--???

--Összetett lekérdezés UNION (Full Outer Join) segítségével.
SELECT m.nev, mer.nev
FROM megnevezes m 
	left join korlatozas k on m.id = k.megnevid
	left join mertek mer on mer.id = k.mertekid
	
union	
	
SELECT m.nev, mer.nev
from mertek mer 
	left join korlatozas k on mer.id = k.mertekid
	left join megnevezes m on m.id = k.megnevid