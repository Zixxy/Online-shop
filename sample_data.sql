insert into konta_uzytkownicy values
('user1','haselko12', 'janb', 'kowali', null),
('user5','proste2haslo1z', 'janc', 'kowala', null),
('user6','proste2haslo1r', 'jand', 'kowalb', null),
('user7','proste2haslo1q', 'jane', 'kowalc', null),
('user8','proste2haslo1w', 'janf', 'kowald', null),
('user9','proste2haslo1u', 'jang', 'kowale', null),
('user10','proste2haslo1i', 'janh', 'kowalf', null),
('user11','proste2haslo1o', 'jani', 'kowalg', null),
('user12','proste2haslo1p', 'janj', 'kowalh', null),
('user13','proste2haslo1a', 'jank', 'kowali', null),
('user14','proste2haslo1s', 'janl', 'kowalj', null),
('user4','proste2hasleex', 'jana', 'kowalk', null),
('user15','proste2haslo1d', 'janm', 'kowalk', null);

insert into produkty(kod_kreskowy, nazwa, stan_biezacy, kategoria) values
(834276, 'jedynka śnieżnobiała', 14, 'farby'),
(59875239, 'pilarka', 10, 'narzedzia'),
(98780065032, 'nozyce do ogrodu', 84, 'ogrod'),
(32322323, 'trutka na szerszenie', 22, 'ogrod'),
(7654567, 'rekawice do gruzu', 66, 'bhp'),
(856783, 'kosiarka pchana 2k', 2, 'ogrod'),
(8765456789, 'farba czarna mat jedynka', 3, 'farby');

insert into kartoteka_towaru(kod_kreskowy, cena_zakupu_netto, cena_sprzedazy_netto, vat) values
(834276, 44.12, 50.12, 23),
(59875239, 129.33, 140.02, 23),
(98780065032, 72.15, 75.32, 23),
(32322323, 5.19, 8.92, 23),
(7654567, 4.02, 5.00, 23),
(856783, 487.33, 512.24, 23),
(8765456789, 17.88, 20.01, 23);

insert into adresy(ulica, miejscowosc, numer_domu, kod_pocztowy) values
('czerwona', 'zalesie', '3c', '34-447'),
('zielonaa', 'przedlesie', '33', '34-448'),
('czerwona', 'podlesie', '12', '24-447'),
('piekna', 'niepiekna', '32f', '31-333'),
('przepiekna', 'niepiekna', '14h', '31-445'),
('bukowa', 'brzozow', '3c', '12-347');

insert into dostawcy(nazwa_dostawcy, nip, adres, numer_konta, parametry_dostawcy) values
('zhu polifarb debica', 9876543211, 1, 98761234987612347281923041, null),
('drutex elektronarzedzia', 9876243211, 2, 98761234987612347281443041, null);

select add_delivery('zhu polifarb debica', 
	ARRAY[834276, 59875239], 
	ARRAY[14, 10], 
	ARRAY[44.12, 129.33], 
	ARRAY[23, 23], 
	now()::date, 
	'numer_factury:33');

select prepare_order('user4', 
	ARRAY[98780065032, 856783, 7654567],
 	ARRAY[1,1,4], 
 	4, 
 	now()::date);