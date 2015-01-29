package Services;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;


public class OrdersService {
	private Connection connection;

	public OrdersService(Connection newConnection){
		connection = newConnection;
	}

	public void executeOrder(int number) throws SQLException{
		DBCommunicator.executeQuery(connection, "select execute_order("+Integer.toString(number)+");");	
	}
	
	public void createInvoice(int number, String paymentForm) throws SQLException{
		DBCommunicator.executeQuery(connection, "select create_invoice("+Integer.toString(number)+", " + paymentForm + ");");
	}
	
	
	public String selectOrders() throws SQLException{
		ResultSet table = DBCommunicator.executeQuery(connection, "select * from zamowienia;");
		if (!table.isBeforeFirst() ) {    
			System.err.println("No data"); 
			return null;
		}
		return DBCommunicator.readTable(table, 5);	
	}

	public String selectUnrealizedOrders() throws SQLException{
		ResultSet table = DBCommunicator.executeQuery(connection, 
				"select * from zamowienia where stan_realizacji = 'oczekuje';");
		if (!table.isBeforeFirst() ) {    
			System.err.println("No data"); 
			return null;
		}
		return DBCommunicator.readTable(table, 5);
	}

	public String selectOrderDetails(int order) throws SQLException {
		ResultSet table = DBCommunicator.executeQuery(connection, 
				"select * from order_details("+Integer.toString(order)+");");
		if (!table.isBeforeFirst() ) {    
			 System.err.println("No data"); 
			 return null;
		}
		return DBCommunicator.readTable(table, 10);
	}
	
	public String selectOrderedProducts(int order) throws SQLException {
		ResultSet table = DBCommunicator.executeQuery(connection, 
				"select * from ordered_products("+Integer.toString(order)+");");
		if (!table.isBeforeFirst() ) {    
			 System.err.println("No data"); 
			 return null;
		}
		return DBCommunicator.readTable(table, 6);
	}
	
	public void addOrder(Scanner inputScanner){
		StringBuilder addQuery = new StringBuilder();
		addQuery.append("select prepare_order('");
		
		System.out.println("login uzytkownika zamawiającego: ");
		addQuery.append(inputScanner.nextLine()+"', ARRAY[");
		
		System.out.println("ilosc produktow: ");
		String numberProducts = inputScanner.nextLine();
		int number = Integer.parseInt(numberProducts);
		
		System.out.println("kolejne kody kreskowe: ");
		for(int i = 0; i < number - 1; ++i){
			addQuery.append(inputScanner.nextLine() + ",");
		}
		addQuery.append(inputScanner.nextLine() + "], ARRAY[");
		
		System.out.println("kolejno ilosc kazdego: ");
		for(int i = 0; i < number - 1; ++i){
			addQuery.append(inputScanner.nextLine() + ",");
		}
		addQuery.append(inputScanner.nextLine() + "],");
		
		System.out.println("adres: ");
		addQuery.append(inputScanner.nextLine() + ",");
		
		System.out.println("podaj datę (dd-mm-yy hh:mm:ss) lub datę teraźniejszą (teraz): ");
		String date = inputScanner.nextLine();
		if(date.equals("teraz"))
			addQuery.append("now()::date);");
		else
			addQuery.append("'" + date + "');");

		try {
			DBCommunicator.executeQuery(connection, addQuery.toString());
			System.out.println("ok");
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("Error. któraś z danych została podana nieprawidłowo.");
			System.out.println("Baza twierdzi że: " + e.getMessage());
		}
	}
	
	public void realizeOrder(int order, String payment_form) throws SQLException{
		try {
			DBCommunicator.execute(connection, 
					"BEGIN; select " + "create_invoice("+Integer.toString(order)+", '" + payment_form + "');" +
					"select " + "execute_order(" + Integer.toString(order)+ "); " + "COMMIT;");
		} catch (SQLException e) {
			try {
				connection.rollback();
			} catch (SQLException e1) {} // not need to printstacktrace due to begin; ... commit; statement above.
			throw e;
		}
	}
}
