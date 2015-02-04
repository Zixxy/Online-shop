package Services;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;


public class DelieveryService {
	private Connection connection;

	public DelieveryService(Connection connection){
		this.connection = connection;
	}

	public void addDelieveryFromConsole(Scanner inputScanner){
		StringBuilder addQuery = new StringBuilder();
		addQuery.append("select add_delivery('");
		
		System.out.println("nazwa dostawcy: ");
		addQuery.append(inputScanner.nextLine()+"', ARRAY[");
		
		System.out.println("ilosc produktow: ");
		String numberProducts = inputScanner.nextLine();
		int number = Integer.parseInt(numberProducts);
		
		System.out.println("kolejne kody kreskowe: ");
		String[] codes = new String[number];
		for(int i = 0; i < number - 1; ++i){
			addQuery.append(inputScanner.nextLine() + ",");
		}
		addQuery.append(inputScanner.nextLine() + "], ARRAY[");
		
		System.out.println("kolejno ilosc kazdego: ");
		for(int i = 0; i < number - 1; ++i){
			addQuery.append(inputScanner.nextLine() + ",");
		}
		addQuery.append(inputScanner.nextLine() + "],ARRAY[");
		
		System.out.println("kolejno ceny: ");
		for(int i = 0; i < number - 1; ++i){
			addQuery.append(inputScanner.nextLine() + ",");
		}
		addQuery.append(inputScanner.nextLine() + "],ARRAY[");
		
		System.out.println("kolejno wartości vat-u: ");
		for(int i = 0; i < number - 1; ++i){
			addQuery.append(inputScanner.nextLine() + ",");
		}
		addQuery.append(inputScanner.nextLine() + "],");
		
		System.out.println("podaj datę (dd-mm-yy hh:mm:ss) lub datę teraźniejszą (teraz): ");
		String date = inputScanner.nextLine();
		if(date.equals("teraz"))
			addQuery.append("now()::date, '");
		else
			addQuery.append("'" + date + "', '");
		System.out.println("numer faktury: ");
		String invoice = inputScanner.nextLine();
		addQuery.append(invoice+"');");
		
		try {
			DBCommunicator.executeQuery(connection, addQuery.toString());
			System.out.println("ok");
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("Error.");
		}
	}

	public void addProviderFromConsole(Scanner inputScanner){
		System.out.println("nazwa przedsiębiorstwa: ");
		String company = inputScanner.nextLine();
		System.out.println("nip(musi być 10 cyfr): ");
		String nip = inputScanner.nextLine();
		System.out.println("numer konta(musi być 26 cyfr): ");
		String accountNumber = inputScanner.nextLine();
		System.out.println("parametry dostawcy: ");
		String parameters = inputScanner.nextLine();
		try {
			int result = DBCommunicator.executeUpdate(connection, "insert into dostawcy(nazwa_dostawcy, nip, numer_konta, parametry_dostawcy) values ('" +
					company + "', '" + nip + "','" + accountNumber + "','" + parameters + "');"
					);
			System.out.println("dodano "+Integer.toString(result));
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public String selectProviders() throws SQLException{
		System.out.println("nazwa dostawcy | nip | numer konta | parametry dostawcy ");
		ResultSet table = DBCommunicator.executeQuery(connection, "select * from dostawcy;");
		if (!table.isBeforeFirst() ) {    
			System.err.println("No data"); 
			return null;
		}
		return DBCommunicator.readTable(table, 4);	
	}
	
	public String selectDeliveries(){
		//todo
		return null;
	}
	
	public void deleteProvider(String nip){
		try {
			int result = DBCommunicator.executeUpdate(connection, "delete from dostawcy where nip = '"+ nip +"';");
			System.out.println("Number deleted: " + result);
		} catch (SQLException e) {
			System.out.println("Wrong input.");
			e.printStackTrace();
		}
	}
}
