drop trigger insert_password on konta_uzytkownicy;
drop trigger insert_nip on dostawcy;
drop trigger insert_numer_konta on dostawcy;
drop trigger insert_dostawy_produkty on dostawy_produkty;

drop table faktury_zakupow cascade;
drop table dostawy_produkty;
drop table dostawy;
drop table kartoteka_towaru;
drop table zamowienia_produkty;
drop table produkty cascade;
drop table dostawcy cascade;
drop table paragon;
drop table faktury_sprzedazy;
drop table zamowienia;
drop table konta_uzytkownicy;
drop table adresy cascade;
drop function hash_passoword();
drop function password_is_correct(varchar, varchar);
drop function order_products(int);
drop function order_details(int);
drop view exhibition;
drop view payments;
drop view product_current_state;

drop type formy_platnosci;
drop type order_worth;
drop type sale_document;