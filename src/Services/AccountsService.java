package Services;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

public class AccountsService {
	private Connection connection;
	public AccountsService(Connection connection){
		this.connection = connection;
		
	}
	
	public String selectAccounts() throws SQLException{
		ResultSet table = DBCommunicator.executeQuery(connection, "select * from konta_uzytkownicy;");
		if (!table.isBeforeFirst() ) {    
			System.err.println("No data"); 
			return null;
		}
		return DBCommunicator.readTable(table, 4);	
	}

	public void addAccountFromConsole(Scanner inputScanner){
		StringBuilder addQuery = new StringBuilder();
		addQuery.append("insert into konta_uzytkownicy values('");
		
		System.out.println("login: ");
		addQuery.append(inputScanner.nextLine()+"','");
		
		System.out.println("haslo: ");
		addQuery.append(inputScanner.nextLine()+"','");
		
		System.out.println("imie: ");
		addQuery.append(inputScanner.nextLine()+"','");
		
		System.out.println("nazwisko: ");
		addQuery.append(inputScanner.nextLine()+"');");
		
		try {
			DBCommunicator.executeUpdate(connection, addQuery.toString());
			System.out.println("Ok.");
		} catch (SQLException e) {
			System.out.println("Error.");
			e.printStackTrace();
		}
	}
	
	public void addAddAddressFromConsole(Scanner inputScanner){
		StringBuilder addQuery = new StringBuilder();
		addQuery.append("insert into adresy(login_użytkownika, ulica, miejscowosc, numer_domu, kod_pocztowy) values('");
		
		System.out.println("login uzytkownika: ");
		addQuery.append(inputScanner.nextLine()+"','");
		
		System.out.println("ulica: ");
		addQuery.append(inputScanner.nextLine()+"','");
		
		System.out.println("miejscowosc: ");
		addQuery.append(inputScanner.nextLine()+"','");
		
		System.out.println("numer domu: ");
		addQuery.append(inputScanner.nextLine()+"','");
		
		System.out.println("kod pocztowy: ");
		addQuery.append(inputScanner.nextLine()+"');");
		
		try {
			DBCommunicator.executeUpdate(connection, addQuery.toString());
			System.out.println("Ok.");
		} catch (SQLException e) {
			System.out.println("Error.");
			e.printStackTrace();
		}
	}
}