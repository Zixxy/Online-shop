drop trigger insert_password on konta_uzytkownicy;
drop trigger insert_nip on dostawcy;
drop trigger insert_numer_konta on dostawcy;
drop trigger insert_dostawy_produkty on dostawy_produkty;
drop trigger remove_account on konta_uzytkownicy;

drop function hash_passoword() cascade;
drop function password_is_correct(varchar, varchar);
drop function ordered_products(int);
drop function order_details(int);
drop function execute_order(int);
drop function delete_account();

drop view payments;
drop view product_current_state;

drop table dostawy_produkty;
drop table dostawy;
drop table zamowienia_produkty;
drop table dostawcy cascade;
drop table faktury_sprzedazy;
drop table zamowienia;
drop table adresy ;
drop table konta_uzytkownicy;
drop table produkty cascade;
drop table kartoteka_towaru;

drop type formy_platnosci cascade;
drop type realization_state cascade;
drop type order_worth cascade;
