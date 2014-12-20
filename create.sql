CREATE TYPE formy_platnosci AS ENUM ('sad', 'ok', 'happy');

CREATE TABLE adresy ( 
	id_adres             serial PRIMARY KEY,
	ulica                varchar(20)  NOT NULL,
	miejscowosc          varchar(20)  NOT NULL,
	numer_domu           varchar(10) NOT NULL,
	kod_pocztowy         char(6)  NOT NULL,
	CONSTRAINT unique_address UNIQUE(ulica, miejscowosc, numer_domu, kod_pocztowy)
 );

CREATE TABLE konta_uzytkownicy ( 
	login                varchar(20)  NOT NULL,
	haslo                char(36)  NOT NULL,
	imie                 varchar(20)  NOT NULL,
	nazwisko             varchar(20)  NOT NULL,
	adres                int,
	CONSTRAINT pk_login PRIMARY KEY ( login ),
	CONSTRAINT fk_adres FOREIGN KEY ( adres ) REFERENCES adresy( id_adres )
 );

CREATE TABLE zamowienia ( 
	id_zamowienia        serial  NOT NULL ,
	login_klienta        varchar(20)  NOT NULL,
	zrealizowane         bool  NOT NULL,
	data_zlozenia        date  NOT NULL DEFAULT NOW(),
	adres    int  NOT NULL,
	CONSTRAINT pk_zamowienia PRIMARY KEY ( id_zamowienia ),
	CONSTRAINT fk_konta_uzytkownicy FOREIGN KEY ( login_klienta ) REFERENCES konta_uzytkownicy( login ),
	CONSTRAINT fk_adresy FOREIGN KEY ( adres ) REFERENCES adresy( id_adres )
 );

CREATE TABLE faktury_sprzedazy ( 
	id_zamowienia        int  NOT NULL,
	nr_faktury 			 varchar(20)  NOT NULL,
	data_wystawienia     date  NOT NULL DEFAULT now(),
	wartosc_netto        numeric(12,2)  NOT NULL,
	wartosc_brutto       numeric(12,2)  NOT NULL,
	forma_platnosci      formy_platnosci NOT NULL,
	CONSTRAINT pk_faktury_sprzedazy PRIMARY KEY ( id_zamowienia ),
 	CONSTRAINT fk_faktury_sprzedazy FOREIGN KEY (id_zamowienia) REFERENCES zamowienia( id_zamowienia )
 );

CREATE TABLE paragon ( 
	id_zamowienia        int  NOT NULL,
	wartosc_netto        numeric(12,2)  NOT NULL,
	wartosc_brutto       numeric(12,2)  NOT NULL,
	forma_platnosci      formy_platnosci NOT NULL,
	CONSTRAINT pk_paragon PRIMARY KEY ( id_zamowienia ),
	CONSTRAINT fk_paragon FOREIGN KEY ( id_zamowienia ) REFERENCES zamowienia( id_zamowienia )
 );

CREATE TABLE dostawcy ( 
	nazwa_dostawcy       varchar(40)  NOT NULL,
	nip                  char(10) NOT NULL,
	adres                int  NOT NULL,
	numer_konta          char(26),
	parametry_dostawcy   varchar(100), -- to learn.
	CONSTRAINT pk_dostawcy PRIMARY KEY ( nazwa_dostawcy ),
	CONSTRAINT idx_dostawcy UNIQUE ( adres ),
 	CONSTRAINT fk_dostawcy FOREIGN KEY ( adres ) REFERENCES adresy( id_adres )
);

CREATE TABLE produkty ( 
	kod_kreskowy         numeric(16),
	nazwa 				 varchar(40),
	stan_biezacy         int,
	kategoria      		 varchar(30),
	opis				 varchar(200),
	CONSTRAINT pk_produkty PRIMARY KEY ( kod_kreskowy )
 );

CREATE TABLE zamowienia_produkty ( 
	produkt              numeric(16)  NOT NULL,
	id_zamowienia        int  NOT NULL,
	ilosc                int  NOT NULL,
	CONSTRAINT pk_zamowienia_produkty PRIMARY KEY ( produkt, id_zamowienia),
	CONSTRAINT fk_zamowienia_produkty FOREIGN KEY ( id_zamowienia ) REFERENCES zamowienia( id_zamowienia ),
	CONSTRAINT fk_zamowienia_produkty_0 FOREIGN KEY ( produkt ) REFERENCES produkty( kod_kreskowy )
 );

CREATE TABLE kartoteka_towaru ( 
	kod_kreskowy         numeric(16)  NOT NULL,
	data_od              date  NOT NULL DEFAULT now(),
	data_do              date,
	cena_zakupu_netto    numeric(6,2),
	cena_sprzedazy_netto numeric(6,2),
	vat                  int,
	CONSTRAINT ck_5 CHECK ( cena_zakupu_netto < cena_sprzedazy_netto),
	CONSTRAINT ck_4	 CHECK ( vat in (0, 5, 7, 8, 23)), 
	CONSTRAINT fk_kartoteka_towaru FOREIGN KEY ( kod_kreskowy ) REFERENCES produkty( kod_kreskowy ),
	CONSTRAINT pk_kartoteka_towaru PRIMARY KEY ( kod_kreskowy, data_od )
 );

CREATE TABLE dostawy ( 
	id_dostawy           serial  NOT NULL,
	nazwa_dostawcy       varchar(40)  NOT NULL,
	CONSTRAINT pk_dostawy PRIMARY KEY ( id_dostawy ),
	CONSTRAINT fk_dostawy FOREIGN KEY ( nazwa_dostawcy ) REFERENCES dostawcy( nazwa_dostawcy ) 
 );

CREATE TABLE dostawy_produkty ( 
	id_dostawy           int  NOT NULL,
	kod_produktu         numeric(16)  NOT NULL,
	ilosc                int  NOT NULL,
	cena_netto 			 numeric(6,2) NOT NULL,
	vat					 int,
	CONSTRAINT ck_3 CHECK ( vat in (0, 5, 7, 8, 23)), 
	CONSTRAINT ck_6 CHECK ( ilosc > 0), 
	CONSTRAINT pk_dostawy_produkty PRIMARY KEY ( id_dostawy, kod_produktu ),
	CONSTRAINT fk_dostawy_produkty FOREIGN KEY ( id_dostawy ) REFERENCES dostawy( id_dostawy ),
	CONSTRAINT fk_dostawy_produkty_0 FOREIGN KEY ( kod_produktu ) REFERENCES produkty( kod_kreskowy )
 );

CREATE TABLE faktury_zakupow ( 
	id_dostawy           int  NOT NULL,
	nr_faktury           varchar(20)  NOT NULL,
	data_wystawienia     date  NOT NULL,
	wartosc_netto        numeric(12,2)  NOT NULL,
	wartosc_brutto       numeric(12,2)  NOT NULL,
	uregulowane			 bool NOT NULL,
	CONSTRAINT pk_faktury_sprzedazy_0 PRIMARY KEY ( id_dostawy ) ,
	CONSTRAINT fk_faktury_zakupow FOREIGN KEY ( id_dostawy ) REFERENCES dostawy( id_dostawy ) 
 );

CREATE INDEX idx_dostawy_produkty ON dostawy_produkty ( kod_produktu );

CREATE INDEX idx_dostawy ON dostawy ( nazwa_dostawcy );

CREATE INDEX idx_kartoteka_towaru ON kartoteka_towaru ( kod_kreskowy );

CREATE INDEX idx_magazyn ON produkty ( nazwa_dostawcy );

CREATE INDEX idx_zamowienia_produkty ON zamowienia_produkty ( id_zamowienia );

CREATE INDEX idx_zamowienia ON zamowienia ( login_klienta );

CREATE INDEX idx_zamowienia_0 ON zamowienia ( adres );

--triggers
CREATE OR REPLACE function nip_correct() returns trigger as $nip_correct$
	declare i char;
	declare k int;
	declare j int := 0;
	begin
		for j in 1..10 loop
			k = substring(NEW.nip from j for 1)::integer;
		end loop;
		return NEW;
	end
$nip_correct$ language plpgsql;

CREATE TRIGGER insert_nip BEFORE INSERT OR UPDATE ON dostawcy
FOR EACH ROW EXECUTE PROCEDURE nip_correct();

CREATE OR REPLACE function numer_konta_correct() returns trigger as $nip_correct$
	declare i char;
	declare k int;
	declare j int := 0;
	begin
		for j in 1..26 loop
			k = substring(NEW.numer_konta from j for 1)::integer;
		end loop;
		return NEW;
	end
$nip_correct$ language plpgsql;

CREATE TRIGGER insert_numer_konta BEFORE INSERT OR UPDATE ON dostawcy
FOR EACH ROW EXECUTE PROCEDURE numer_konta_correct();

create or replace function hash_passoword() returns trigger as $hash_passoword$
      begin
           if char_length(NEW.haslo) < 6
           		then raise exception 'password is too short.';
           end if;
           NEW.haslo:= crypt(NEW.haslo, gen_salt('md5'));
           return NEW;
      end
$hash_passoword$ language plpgsql;

CREATE TRIGGER insert_password BEFORE INSERT OR UPDATE ON konta_uzytkownicy
FOR EACH ROW EXECUTE PROCEDURE hash_passoword();
--functions
CREATE or replace function password_is_correct(varchar, varchar) returns bool 
as
$$
	select haslo = crypt($2, haslo) 
	from konta_uzytkownicy
	where $1 = konta_uzytkownicy.login;
$$ language sql;


CREATE or replace function order_products(int) returns 
table(nazwa varchar(40),kategoria varchar(40),
ilosc int, cena_sprzedazy_netto numeric(6,2),
cena_sprzedazy_brutto numeric(6,2), vat int)
as
$$
	select produkty.nazwa, 
		produkty.kategoria, 
		zamowienia_produkty.ilosc,
		kartoteka_towaru.cena_sprzedazy_netto,
		kartoteka_towaru.cena_sprzedazy_netto*(100+vat::numeric(6,2)) as cena_sprzedazy_brutto,
		kartoteka_towaru.vat as "vat"
	from zamowienia
	join zamowienia_produkty
	on zamowienia_produkty.id_zamowienia = zamowienia.id_zamowienia
	join produkty
	on zamowienia_produkty.produkt = produkty.kod_kreskowy
	join kartoteka_towaru
	on kartoteka_towaru.kod_kreskowy = produkty.kod_kreskowy
	and kartoteka_towaru.data_do is null --price spaces until now
	where zamowienia.id_zamowienia = $1;
$$ language sql;

CREATE or replace function order_details(int) returns table(
	imie varchar, nazwisko varchar, ulica varchar, miejscowosc varchar, 
	numer_domu varchar, kod_pocztowy char(6), data_zlozenia date,
	zrealizowane bool, wartosc_netto numeric(6,2), wartosc_brutto numeric(6,2)
)
as
$$
	select ku.imie, ku.nazwisko, a.ulica, a.miejscowosc, a.numer_domu, a.kod_pocztowy,
	z.data_zlozenia,
	z.zrealizowane, (
		select 
			sum(cena_sprzedazy_netto)
		from order_products($1)
		) as wartosc_netto, (
		select
			sum(cena_sprzedazy_brutto)
		from order_products($1)
		) as wartosc_brutto
	from zamowienia z
	join konta_uzytkownicy ku
	on z.login_klienta = ku.login
	join adresy a
	on a.id_adres = z.adres
	where z.id_zamowienia = $1
$$ language sql;

CREATE or REPLACE function add_delivery(varchar, numeric(16)[], int[], numeric(16,2)[], int[],data date,numer_faktury varchar)
returns void
as 
$$
	declare product_code numeric(16);
	declare id int;
	declare iterator int := 1;
	declare net_value numeric(6,2) := 0;
	declare gross_value numeric(6,2) := 0;
	begin
		if (select nazwa_dostawcy from dostawcy where $1 = nazwa_dostawcy) is NULL
		then raise exception 'No such provider in database';
		end if;
		foreach product_code in ARRAY $2 loop
			if (select kod_kreskowy from produkty where product_code = kod_kreskowy) is null
			then raise exception 'No such product in database';
			end if;
		end loop;
		insert into dostawy(nazwa_dostawcy) values
			($1);
		select into id currval('dostawy_id_dostawy_seq');
		foreach product_code in ARRAY $2 loop
			net_value := net_value + $4[iterator];
			gross_value := gross_value + $4[iterator]*($5[iterator]::numeric(6,2));
			insert into dostawy_produkty(id_dostawy, kod_produktu, ilosc, cena_netto) values
			(id, product_code, $3[iterator], $4[iterator]);
			iterator := iterator + 1;
		end loop;
		insert into faktury_zakupow(id_dostawy, nr_faktury, data_wystawienia, wartosc_netto, wartosc_brutto, uregulowane) values
		(id, numer_faktury, data, net_value, gross_value, false);
	end
$$ language plpgsql;
--VIEWS

CREATE VIEW  exhibition as
select 
	case when nazwa = null
	then
		kod_towarowy
	else
		nazwa as nazwa, cena_detaliczna as cena, opis as opis
from magazyn;

CREATE VIEW payments as
SELECT
	dy.nazwa_dostawcy,
	dy.numer_konta,
	f.nr_faktury,
	f.data_wystawienia,
	f.wartosc_netto,
	f.wartosc_brutto,
	f.forma_platnosci
FROM faktury_zakupow f
JOIN dostawy d 
on d.id_dostawy = f.id_dostawy
JOIN dostawcy dy 
on d.nazwa_dostawcy = dy.nazwa_dostawcy
where f.uregulowane; 