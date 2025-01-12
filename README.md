# Movielens
School project


Krátke vysvetlenie témy projektu MovieLens, typ dát a účel analýzy:
Projekt MovieLens predstavuje rozsiahlu databázu filmových hodnotení vytvorených používateľmi. Obsahuje dáta o filmoch, používateľoch a ich hodnoteniach (ratings), prípadne aj tagy, či časové údaje o hodnoteniach. Tieto údaje sú typicky využívané na tvorbu odporúčacích systémov (recommendation systems), analýzy preferencií používateľov, skúmanie popularít žánrov, filmov a pod.

Typ dát:
Hlavne textové atribúty (názvy filmov, žánre, mená používateľov a ich charakteristiky), číselné (hodnotenia, ID, roky, dátumy), dátovo-časové (čas/ dátum hodnotenia).
Účel analýzy: cieľom je získať prehľad o tom, aké filmy sa najviac hodnotia, aké žánre sú obľúbené, akí používatelia ich hodnotia, v akom čase prebieha najviac hodnotení či ako sa hodnotenia menia naprieč demografickými ukazovateľmi.



Základný popis každej tabuľky zo zdrojových dát a ich význam:

Movies 
Hlavné stĺpce: movieId, title, genres
Význam: Zahŕňa informácie o filmoch, ich názvy a žánre. Pre analýzy môžeme filmovú entitu spájať s konkrétnymi hodnoteniami.

Ratings
Hlavné stĺpce: userId, movieId, rating, timestamp
Význam: Zaznamenávajú hodnotenia filmov jednotlivými používateľmi na škále od 0,5 po 5 (podľa verzie datasetu). timestamp predstavuje čas vytvorenia hodnotenia.

Tags
Hlavné stĺpce: userId, movieId, tag, timestamp
Význam: Umožňujú používateľom priraďovať k filmom tagy (krátke textové popisy, napr. “thriller”, “based on a true story”), ktoré vystihujú film z pohľadu používateľa.

Users
Hlavné stĺpce: userId, prípadne demografické informácie (pohlavie, veková skupina, povolanie, PSČ a pod.) – to závisí od verzie datasetu.
Význam: Obsahuje informácie o demografii a iných atribútoch používateľov, na základe ktorých môžeme analyzovať rozdiely v preferenciách.

Time/Date
Vo väčšine datasetov MovieLens čas nie je v samostatnej tabuľke, ale je uložený v stĺpci timestamp. Pri potrebe detailných analýz (napr. dňa v týždni, času počas dňa) sa zvyčajne extrahuje do samostatnej tabuľky.
(Názvy tabuliek sa môžu mierne líšiť podľa konkrétnej verzie datasetu, ale princíp ostáva rovnaký.)

ERD diagram pôvodnej štruktúry zdrojových dát

Nižšie je príklad jednoduchej schémy vzťahov (pôvodná štruktúra MovieLens datasetu). Vzťahy sú:

Ratings je prepojovacia tabuľka medzi Users a Movies (1 používateľ môže ohodnotiť viac filmov, 1 film môže byť ohodnotený viacerými používateľmi).
Tags je obdobne prepojovacia tabuľka medzi Users a Movies (1 používateľ môže pridávať tagy k viacerým filmom a 1 film môže mať viacero tagov).

![alt text](image.png)

Prípadne, ak existuje samostatná tabuľka Time/Date, tak Ratings a Tags budú mať cudzie kľúče na túto tabuľku.



Návrh dimenzionálneho modelu typu hviezda (Hviezdička)

V dimenzionálnom modeli zvyčajne zoskupíme číselné a merateľné údaje do jednej faktovej tabuľky a opisné údaje do dimenzných tabuliek.

Faktová tabuľka:
fact_ratings (obsahuje všetky merateľné údaje: rating, počet hodnotení, dátum hodnotenia, a kľúče na dimenzie)

Dimenzie:
dim_users 
dim_movies 
dim_date 
dim_tags 

ERD dimenzionálneho modelu (Hviezdička):
![alt text](image-1.png)
