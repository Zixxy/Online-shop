package UserCommunication;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Scanner;

import Services.AccountsService;
import Services.DelieveryService;
import Services.OrdersService;
import Services.Payments;
import Services.ProductsService;

/*
 * Textowy interface. 
 * Aby zrobić coś na bazie danych np: insert/update/delete odwołujemy się tekstem słów kluczowych połączonych spacjami.
 * Pierwsze słowo to odwołanie do dziedziny:
 * zamowienia
 * dostawcy
 * dostawa
 * konto
 * produkty
 * platnosci
 *
 *
 * możliwości zamowien:
 * komendy:
 * "zamowienia" wypisuje wszystkie zamowienia w bazie danych.
 * "zamowienia nie_zrealizowane" wypisuje niezrealizowane zamowienia.
 * "zamowienia detale [numer]" wypisuje detale konretnego zamowienia.
 * "zamowienia zamowione_produkty [numer]" wypisuje zamowione produkty w konretnym zamowieniu.
 * "zamowienia zrealizuj [numer] [forma platnosci]" podejmuje próbę zrealizowania zamówienia o konkretnym numerze z podaną formą płatności.
 * "zamowienia dodaj "dodaje zamowienie dla pewnego uzytkownika. Przy wprowadzaniu danych prowadzi nas odpowiedni program.
 * 
 * * produkty:
 * komendy:
 * "produkty" wyświetla informacje o produktach
 * "produkty dodaj" dodaje produkt do bazy danych. Przy wprowadzaniu prowadzi nas odpowiedni program prosząc o nazwę, kod kreskowy itd.
 * "produkty zaktualizuj" aktualizujemy cenę produktu. Prowadzi nas odpowiedni program..
 * 
 * platnosci:
 * komendy:
 * "platnosci" wypisuje wszystkie zalegające płatności.
 * "platnosci zaplac [numer]" realizujemy konkretną płatność.
 * 
 * dostawcy:
 * komendy:
 * "dostawcy" wypisuje wszystkich dostawców
 * "dostawcy dodaj" dodajemy nowego dostawcę, prowadzi nas odpowiedni program. W sensie prosi o nazwę, numer konta itd...
 * "dostawcy usun [nip]" usuwamy konretnego dostawcę. 
 * 
 * dostawy:
 * komendy:
 * "dostawy dodaj" dodajemy nową dostawę, prowadzi nas odpowiedni program, instruuje o okolejnych elementach do wpisania.
 * 
 * konta:
 * komendy:
 * "konta" wyświetla dane wszystkich kont w bazie danych.
 * "konta dodaj" dodaje nowe kotno, prowadzi nas odpowiedni program.
 * 
 * komenda
 * "exit" uprzejmie kończy pracę programu.
 * 
 */
public class UserCommunicator implements Runnable {

	private boolean active;
	private Connection connection;
	
	private static final String EXIT = "exit";
	private static final String NOT_REALIZED = "nie_zrealizowane";
	private static final String DETAILS = "detale";
	private static final String PRODUCTS = "zamowione_produkty";
	private static final String REALIZE = "zrealizuj";
	private static final String PAY = "zaplac";
	private static final String ADD = "dodaj";
	private static final String UPDATE = "zaktualizuj";
	private static final String DELETE = "usun";
	
	private static final String ORDER = "zamowienia";
	private static final String PROVIDERS = "dostawcy";
	private static final String DLIEVERY = "dostawy";
	private static final String ACCOUNT = "konta";
	private static final String PRODUCT = "produkty";
	private static final String PAYMENTS = "platnosci";
	
	private OrdersService ordersService;
	private Payments payments;
	private DelieveryService delieveries;
	private AccountsService accounts;
	private ProductsService products;
	
	public UserCommunicator(Connection connection){
		this.connection = connection;
		ordersService = new OrdersService(connection);
		payments = new Payments(connection);
		delieveries = new DelieveryService(connection);
		accounts = new AccountsService(connection);
		products = new ProductsService(connection);
	}
	
	@Override
	public void run() {
		active = true;
		Scanner inputScanner = new Scanner (System.in);
		
		while(active) {
			System.out.println("Wykonaj: ");
			String line = inputScanner.nextLine();
			try {
				handleInput (line, inputScanner);
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		
		inputScanner.close();
	}
	
	public void exit(){
		active = false;
		try {
			connection.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public void handleInput(String line,Scanner inputScanner) throws SQLException{
		if(line == null)
			return;
		if(line.equals(EXIT)){
			active = false;
		}
		
		String[] request = line.split(" ");
		switch(request[0]){
		case ORDER:
			executeOrder(request, inputScanner);
			break;
		case PAYMENTS:
			executePayment(request);
			break;
		case PROVIDERS:
			operateOnProviders(request, inputScanner);
			break;
		case DLIEVERY:
			operateOnDelieveries(request, inputScanner);
			break;
		case ACCOUNT:
			accountOperations(request, inputScanner);
			break;
		case PRODUCT:
			productsOperations(request, inputScanner);
			break;
		case EXIT:
			exit();
			return;
		}
	}
	public void productsOperations(String[] request, Scanner inputScanner)  throws SQLException{
		if(request.length == 1) {
			System.out.println(products.selectProductsCurrentState());
			return;
		}
		switch(request[1]){
		case ADD:
			products.addProductFromConsole(inputScanner);
			break;
		case UPDATE:
			products.updateProductPrice(inputScanner);
			break;
		}
	}
	public void accountOperations(String[] request, Scanner inputScanner) throws SQLException{
		if(request.length == 1) {
			System.out.println(accounts.selectAccounts());
			return;
		}
		
		switch(request[1]){
		case ADD:
			accounts.addAccountFromConsole(inputScanner);
			break;
		}
	}
	
	public void operateOnDelieveries(String[] request, Scanner inputScanner){
		if(request.length == 1){
			//todo
			return;
		}
		switch(request[1]){
		case ADD: 
			delieveries.addDelieveryFromConsole(inputScanner);
			break;
		default:
			return;
		}
	}
	
	public void operateOnProviders(String[] request, Scanner inputScanner) throws SQLException {
		if(request.length == 1){
			System.out.println(delieveries.selectProviders());
			return;
		}
		if(request[1].equals(ADD))
			delieveries.addProviderFromConsole(inputScanner);
		else if(request[1].equals(DELETE))
			delieveries.deleteProvider(request[2]);
	}

	public void executePayment(String[] request) throws SQLException {
		if(request.length == 1){
			System.out.println(payments.selectPayments());
			return;
		}
		if(request[1].equals(PAY)){
			if(payments.payForDelivery(request[2]) > 0)
				System.out.println("OK.");
			else{
				System.out.println("Error.");
			}
		}
	}

	public void executeOrder(String[] request, Scanner inputScanner) throws SQLException{
		if(request.length == 1){
			System.out.println(ordersService.selectOrders());
			return;
		}
		switch(request[1]){
		case NOT_REALIZED:
			System.out.println(ordersService.selectUnrealizedOrders());
			break;
		case DETAILS:
			System.out.println(ordersService.selectOrderDetails(Integer.parseInt(request[2])));
			break;
		case PRODUCTS:
			System.out.println(ordersService.selectOrderedProducts(Integer.parseInt(request[2])));
			break;
		case REALIZE:
			try{
				ordersService.realizeOrder(Integer.parseInt(request[2]), request[3]);
				System.out.println("Ok.");
			} catch (SQLException e) {
				e.printStackTrace();
				System.out.println("Error.");
			}
			break;
		case ADD:
			ordersService.addOrder(inputScanner);
			break;
		default:
				System.out.println("Wrong query.");
		}
	}
}
