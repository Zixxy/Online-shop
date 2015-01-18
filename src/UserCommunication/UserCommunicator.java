package UserCommunication;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Scanner;

import Services.AccountsService;
import Services.DelieveryService;
import Services.OrdersService;
import Services.Payments;


public class UserCommunicator implements Runnable {

	private boolean active;
	private Connection connection;
	
	private static final String EXIT = "exit";
	private static final String ORDER = "zamowienia";
	private static final String NOT_REALIZED = "nie_zrealizowane";
	private static final String DETAILS = "detale";
	private static final String PRODUCTS = "zamowione_produkty";
	private static final String REALIZE = "zrealizuj";
	private static final String PAYMENTS = "platnosci";
	private static final String PAY = "zaplac";
	private static final String PROVIDERS = "dostawcy";
	private static final String DLIEVERY = "dostawa";
	private static final String ADD = "dodaj";
	private static final String ACCOUNT = "konto";
	
	private OrdersService ordersService;
	private Payments payments;
	private DelieveryService delieveries;
	private AccountsService accounts;
	
	public UserCommunicator(Connection connection){
		this.connection = connection;
		ordersService = new OrdersService(connection);
		payments = new Payments(connection);
		delieveries = new DelieveryService(connection);
		accounts = new AccountsService(connection);
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
			executeOrder(request);
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
		case EXIT:
			exit();
			return;
		}
	}
	
	public void accountOperations(String[] request, Scanner inputScanner) throws SQLException{
		if(request.length == 1) {
			accounts.selectAccounts();
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

	public void executeOrder(String[] request) throws SQLException{
		if(request.length == 1){
			System.out.println(ordersService.selectOrders());
			return;
		}
		switch(request[1]){
		case NOT_REALIZED:
			System.out.println(ordersService.selectUnrealizedOrders());
		case DETAILS:
			System.out.println(ordersService.selectOrderDetails(Integer.parseInt(request[2])));
		case PRODUCTS:
			System.out.println(ordersService.selectOrderedProducts(Integer.parseInt(request[2])));
		case REALIZE:
			try{
				ordersService.realizeOrder(Integer.parseInt(request[2]), request[3]);
				System.out.println("Ok.");
			} catch (SQLException e) {
				e.printStackTrace();
				System.out.println("Error.");
			}
			break;
		default:
				System.out.println("Wrong query.");
		}
	}
}
