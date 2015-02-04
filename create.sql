CREATE TYPE formy_platnosci AS ENUM ('karta', 'paragon');
CREATE TYPE realization_state AS ENUM('oczekuje', 'anulowane', 'zrealizowane');

CREATE TYPE order_worth as(
	order_id integer,
	net_value numeric(8,2),
	gross_value numeric(8,2)
);

CREATE TABLE konta_uzytkownicy ( 
	login                varchar(20)  NOT NULL  ,
	haslo                varchar(40)  NOT NULL  ,
	imie                 varchar(20)  NOT NULL  ,
	nazwisko             varchar(20)  NOT NULL  ,
	CONSTRAINT pk_login PRIMARY KEY ( login ),
	CONSTRAINT haslo_zalozenia CHECK ( char_length(haslo) > 6 )
 );

CREATE TABLE adresy (
	id_adres             serial  NOT NULL,
	login_użytkownika    varchar(20)  NOT NULL,
	ulica                varchar(20)  NOT NULL,
	miejscowosc          varchar(20)  NOT NULL,
	numer_domu           varchar(5)  NOT NULL,
	kod_pocztowy         char(6)  NOT NULL,
	CONSTRAINT pk_adresy PRIMARY KEY ( id_adres ),
 	CONSTRAINT fk_adresy FOREIGN KEY ( login_użytkownika ) REFERENCES konta_uzytkownicy(login)
 );

CREATE TABLE zamowienia ( 
	id_zamowienia        serial  NOT NULL ,
	login_klienta        varchar(20), --jesli uzytkownik zostal usuniety a mimo to chcemy pamietac zamowienia.
	data_zlozenia        date  NOT NULL DEFAULT NOW(),
	adres    			 int  NOT NULL,
	stan_realizacji		 realization_state NOT NULL,
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
 	CONSTRAINT fk_faktury_sprzedazy FOREIGN KEY ( id_zamowienia ) REFERENCES zamowienia( id_zamowienia )
 );

CREATE TABLE dostawcy ( 
	nazwa_dostawcy       varchar(40)  NOT NULL,
	nip                  char(10) NOT NULL,
	numer_konta          char(26),
	parametry_dostawcy   varchar(100), -- to ask
	CONSTRAINT pk_dostawcy PRIMARY KEY ( nazwa_dostawcy )
);

CREATE TABLE produkty ( 
	kod_kreskowy         numeric(16),
	nazwa 				 varchar(40),
	stan_biezacy         int,
	kategoria      		 varchar(30),
	opis				 varchar(200),
	CONSTRAINT pk_produkty PRIMARY KEY ( kod_kreskowy ),
	CONSTRAINT dodatni_stan_biezacy  CHECK ( stan_biezacy >= 0)
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
	cena_zakupu_netto    numeric(8,2),
	cena_sprzedazy_netto numeric(8,2),
	vat                  int,
	CONSTRAINT fk_kartoteka_towaru FOREIGN KEY ( kod_kreskowy ) REFERENCES produkty( kod_kreskowy ),
	CONSTRAINT pk_kartoteka_towaru PRIMARY KEY ( kod_kreskowy, data_od )
 );

CREATE TABLE dostawy ( 
	id_dostawy           serial  NOT NULL,
	nazwa_dostawcy       varchar(40)  NOT NULL,
	nr_faktury           varchar(20)  NOT NULL,
	data_wystawienia_faktury     date  NOT NULL,
	wartosc_netto        numeric(12,2)  NOT NULL,
	wartosc_brutto       numeric(12,2)  NOT NULL,
	uregulowane			 bool NOT NULL,
	CONSTRAINT pk_dostawy PRIMARY KEY ( id_dostawy ),
	CONSTRAINT fk_dostawy FOREIGN KEY ( nazwa_dostawcy ) REFERENCES dostawcy( nazwa_dostawcy ) 
 );

CREATE TABLE dostawy_produkty ( 
	id_dostawy           int  NOT NULL,
	kod_produktu         numeric(16)  NOT NULL,
	ilosc                int  NOT NULL,
	cena_netto 			 numeric(8,2) NOT NULL,
	vat					 int,
	CONSTRAINT ck_3 CHECK ( vat in (0, 5, 7, 8, 23)), 
	CONSTRAINT ck_6 CHECK ( ilosc > 0), 
	CONSTRAINT pk_dostawy_produkty PRIMARY KEY ( id_dostawy, kod_produktu ),
	CONSTRAINT fk_dostawy_produkty FOREIGN KEY ( id_dostawy ) REFERENCES dostawy( id_dostawy ),
	CONSTRAINT fk_dostawy_produkty_0 FOREIGN KEY ( kod_produktu ) REFERENCES produkty( kod_kreskowy )
 );

CREATE INDEX idx_dostawy_produkty ON dostawy_produkty ( kod_produktu );

CREATE INDEX idx_dostawy ON dostawy ( nazwa_dostawcy );

CREATE INDEX idx_kartoteka_towaru ON kartoteka_towaru ( kod_kreskowy );

CREATE INDEX idx_zamowienia_produkty ON zamowienia_produkty ( id_zamowienia );

CREATE INDEX idx_zamowienia_produkty_0 ON zamowienia_produkty ( produkt );

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

CREATE OR REPLACE function update_magazine_state() returns trigger as $update_magazine_state$
	begin
		update produkty set stan_biezacy = stan_biezacy + NEW.ilosc
			where produkty.kod_kreskowy = NEW.kod_produktu;
		return NEW;
	end
$update_magazine_state$ language plpgsql;

CREATE TRIGGER insert_dostawy_produkty BEFORE INSERT OR UPDATE ON dostawy_produkty
FOR EACH ROW EXECUTE PROCEDURE update_magazine_state(); --dodając dostawę powiększamy magazyn

CREATE OR REPLACE function insert_invoice() returns trigger as $insert_invoice$
	declare prev_num int;
	declare prev_date date;
	begin
		prev_num = (select nr_faktury from faktury_sprzedazy order by data_wystawienia desc, nr_faktury desc limit 1);
		prev_date = (select data_wystawienia from faktury_sprzedazy order by data_wystawienia desc, nr_faktury desc limit 1);

		if prev_num is null 
		then prev_num = 0;
		end if;

		if prev_date is null
		then prev_date = now();
		end if;

		if (select extract(year from prev_date)) - (select extract(year from NEW.data_wystawienia)) = 1
		then prev_num = 0;
		end if;

		NEW.nr_faktury = prev_num + 1;
		return NEW;
	end
$insert_invoice$ language plpgsql;

CREATE TRIGGER insert_faktury_sprzedazy BEFORE INSERT OR UPDATE ON faktury_sprzedazy
FOR EACH ROW EXECUTE PROCEDURE insert_invoice(); --każdy kolejny numer faktury jest o 1 większy niż poprzedni. Co roku licznik zerujemy i na nowo numerujemy od 1.
--functions


CREATE or replace function password_is_correct(varchar, varchar) returns bool 
as
$$
	select haslo = crypt($2, haslo) 
	from konta_uzytkownicy
	where $1 = konta_uzytkownicy.login;
$$ language sql;


CREATE or replace function ordered_products(int) returns 
table(nazwa varchar(40), kategoria varchar(40),
ilosc int, cena_sprzedazy_netto numeric(8,2), --podaje cenę jaka obowiązywała w momencie złożenia zamówienia. (Ewentualna zmiana w górę z różnych przyczyn będzie skutkowała zmianą statusu zamówienia na anulowane.)
cena_sprzedazy_brutto numeric(8,2), vat int)
as
$$
	select produkty.nazwa, 
		produkty.kategoria, 
		zamowienia_produkty.ilosc,
		kartoteka_towaru.cena_sprzedazy_netto,
		(kartoteka_towaru.cena_sprzedazy_netto*(100+vat::numeric(8,2)) * 0.01) as cena_sprzedazy_brutto,
		kartoteka_towaru.vat as "vat"
	from zamowienia
	join zamowienia_produkty
	on zamowienia_produkty.id_zamowienia = zamowienia.id_zamowienia
	join produkty
	on zamowienia_produkty.produkt = produkty.kod_kreskowy
	join kartoteka_towaru
	on kartoteka_towaru.kod_kreskowy = produkty.kod_kreskowy
	and (zamowienia.data_zlozenia >= kartoteka_towaru.data_od) 
	and (kartoteka_towaru.data_do is null or kartoteka_towaru.data_do > zamowienia.data_zlozenia) --price spaces until now
	where zamowienia.id_zamowienia = $1;
$$ language sql;

--select * from zamowienia z join konta_uzytkownicy k on z.login_klienta = k.login; 
CREATE or replace function order_details(int) returns table(
	imie varchar, nazwisko varchar, ulica varchar, miejscowosc varchar, 
	numer_domu varchar, kod_pocztowy char(6), data_zlozenia date,
	stan_realizacji realization_state, wartosc_netto numeric(8,2), wartosc_brutto numeric(8,2)
)
as
$$
	select ku.imie, ku.nazwisko, a.ulica, a.miejscowosc, a.numer_domu, a.kod_pocztowy,
	z.data_zlozenia, z.stan_realizacji, (
		select 
			sum(cena_sprzedazy_netto * ilosc)
		from ordered_products($1)
		) as wartosc_netto, (
		select
			sum(cena_sprzedazy_brutto * ilosc)
		from ordered_products($1)
		) as wartosc_brutto
	from zamowienia z
	join konta_uzytkownicy ku
	on z.login_klienta = ku.login
	join adresy a
	on a.id_adres = z.adres
	where z.id_zamowienia = $1
$$ language sql;

CREATE or REPLACE function add_delivery(varchar, numeric(16)[], int[], numeric(16,2)[], int[],invoice_date date,numer_faktury varchar)
returns void
as 
$$
	declare product_code numeric(16);
	declare id int;
	declare iterator int := 1;
	declare net_value numeric(8,2) := 0;
	declare gross_value numeric(8,2) := 0;
	begin
		if (select nazwa_dostawcy from dostawcy where $1 = nazwa_dostawcy) is NULL
		then raise exception 'No such provider in database';
		end if;
		foreach product_code in ARRAY $2 loop
			if (select kod_kreskowy from produkty where product_code = kod_kreskowy) is null
			then raise exception 'No such product in database';
			end if;
		end loop;
		
		foreach product_code in ARRAY $2 loop
			net_value := net_value + $4[iterator]*$3[iterator];--wartość netto * ilość
			gross_value := gross_value + $4[iterator]*(1+($5[iterator]::numeric(8,2) / 100))*$3[iterator];--wartość brutto * ilość
			iterator := iterator + 1;
		end loop;
		
		insert into dostawy(nazwa_dostawcy, nr_faktury, data_wystawienia_faktury, wartosc_netto, wartosc_brutto, uregulowane) values
			($1, numer_faktury, invoice_date, net_value, gross_value, false);

		select into id currval('dostawy_id_dostawy_seq');

		iterator := 1;
		foreach product_code in ARRAY $2 loop
			insert into dostawy_produkty(id_dostawy, kod_produktu, ilosc, cena_netto) values
			(id, product_code, $3[iterator], $4[iterator]);
			iterator := iterator + 1;
		end loop;
	end
$$ language plpgsql;

CREATE OR REPLACE function prepare_order(customer varchar,products numeric(16)[],amount int[], 
	address int, order_date date) --przygotowuje zamówienie z datą obecną
returns order_worth
as
$$	
	declare product numeric(16);
	declare iterator integer := 1;
	declare id int;
	declare net_value numeric(8,2) := 0;
	declare gross_value numeric(8,2) := 0;
	declare result order_worth;
	declare order_date date := now();
begin
	if (select customer from konta_uzytkownicy where  customer = konta_uzytkownicy.login) is NULL
		then raise exception 'No such customer in database';
	end if;
	foreach product in ARRAY products loop
		if (select kod_kreskowy from produkty where product = kod_kreskowy) is null
			then raise exception 'No such product in database';
		end if;
	end loop;
	insert into zamowienia(login_klienta, data_zlozenia, adres, stan_realizacji) values
	(customer, order_date, address, 'oczekuje');
	select into id currval('zamowienia_id_zamowienia_seq');

	foreach product in ARRAY products loop
		net_value := net_value + (
			SELECT cena_sprzedazy_netto 
			from product_current_state
			where kod_kreskowy = product);
		gross_value := gross_value + (
			SELECT cena_sprzedazy_netto*(1+(vat::numeric(8,2) / 100))
			from product_current_state
			where kod_kreskowy = product
			);
		insert into zamowienia_produkty(produkt, id_zamowienia, ilosc) values
		(product, id, amount[iterator]);	
		iterator:= iterator + 1;
	end loop;
	result.order_id = id;
	result.net_value = net_value;
	result.gross_value = gross_value;
	return result;
end
$$ language plpgsql;

CREATE OR REPLACE function execute_order(int) returns void --realizujemy zamówienie. (uznajemy za sprzedane ale nie wystawiamy faktury!! Robi to osobna funkcja, która powinna być wywołana przed tą.)
as 
$$
	begin
		create table temp_table(
			nazwa, kategoria, ilosc, cena_sprzedazy_netto, cena_sprzedazy_brutto
		) as (select * from ordered_products($1));

		update produkty ap 
		set stan_biezacy = (
			select bp.stan_biezacy - tt.ilosc
			from produkty bp
			join temp_table tt
			on bp.nazwa = tt.nazwa
			where bp.kod_kreskowy = ap.kod_kreskowy
		) where ap.nazwa = any (select nazwa from temp_table); 

		update zamowienia
		set stan_realizacji = 'zrealizowane'
		where zamowienia.id_zamowienia = $1;

		drop table temp_table;
	end	
$$ language plpgsql;


CREATE OR REPLACE function create_invoice(int, formy_platnosci) returns void --wystawia fakturę za towar, dodatkowo sprawdza czy cena wystawiona teraz pokrywa się lub jest niższa od ceny z momentu założenia zamówienia(zakładamy że klient się ucieszy z ewentualnego upustu). Wpp rzuca wyjątkiem.
as
$$
	declare current_worth numeric(8,2);
	begin
		create table temp_table(
			wartosc_netto, wartosc_brutto
		) as (select wartosc_netto, wartosc_brutto from order_details($1));

		current_worth = (select sum(kartoteka_towaru.cena_sprzedazy_netto*(100+vat::numeric(8,2))*zamowienia_produkty.ilosc)
		from zamowienia
		join zamowienia_produkty
		on zamowienia_produkty.id_zamowienia = zamowienia.id_zamowienia
		join produkty
		on zamowienia_produkty.produkt = produkty.kod_kreskowy
		join kartoteka_towaru
		on kartoteka_towaru.kod_kreskowy = produkty.kod_kreskowy
		and kartoteka_towaru.data_do is null --price spaces until now
		where zamowienia.id_zamowienia = $1);

		insert into faktury_sprzedazy(id_zamowienia, nr_faktury, data_wystawienia, wartosc_netto, wartosc_brutto, forma_platnosci) values	
		($1, 5, now(), (select wartosc_netto from temp_table), (select wartosc_brutto from temp_table), $2);

		drop table temp_table;
	end
$$ language plpgsql;

CREATE OR REPLACE function updateProductPrice(kod numeric(16), sell_pirce numeric(16,2),buy_price numeric(16,2), vat int) returns void
as
$$
	declare existance int;
	begin
		existance = (select count(*) from produkty where kod = produkty.kod_kreskowy);
		if existance = 0
		then raise exception 'Product does not exist!';
		end if;

		update kartoteka_towaru kt
			set data_do = (
					select now()
				) where kt.kod_kreskowy = kod and data_do is null;

		insert into kartoteka_towaru(kod_kreskowy, cena_zakupu_netto, cena_sprzedazy_netto, vat) values
			(kod, buy_price, sell_pirce, vat);
	end
$$ language plpgsql;
--test	
--CREATE or REPLACE function order()
--VIEWS

CREATE VIEW payments as
SELECT
	d.id_dostawy,
	dy.nazwa_dostawcy,
	dy.numer_konta,
	d.nr_faktury,
	d.data_wystawienia_faktury,
	d.wartosc_netto,
	d.wartosc_brutto
FROM dostawy d
JOIN dostawcy dy 
on d.nazwa_dostawcy = dy.nazwa_dostawcy
where d.uregulowane = false; 

CREATE VIEW product_current_state as
SELECT
	p.kod_kreskowy,
	p.nazwa, 
	p.stan_biezacy,
	p.kategoria,
	p.opis,
	kt.data_od,
	kt.cena_zakupu_netto,
	kt.cena_sprzedazy_netto,
	kt.vat
from produkty p
join kartoteka_towaru kt
on p.kod_kreskowy = kt.kod_kreskowy
and kt.data_do is null;



