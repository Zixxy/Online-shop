package Services;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

public class ProductsService {

	private Connection connection;
	public ProductsService(Connection connection){
		this.connection = connection;
	}
	
	public String selectProductsCurrentState() throws SQLException{
		ResultSet table = DBCommunicator.executeQuery(connection, "select * from product_current_state;");
		if (!table.isBeforeFirst() ) {    
			System.err.println("No data"); 
			return null;
		}
		return DBCommunicator.readTable(table, 9);	
	}
	/*
	 * insert into produkty(kod_kreskowy, nazwa, stan_biezacy, kategoria) values
(834276, 'jedynka śnieżnobiała', 14, 'farby'),
	 */
	public void addProductFromConsole(Scanner inputScanner){
		StringBuilder createProductFile = new StringBuilder("insert into kartoteka_towaru(kod_kreskowy, cena_zakupu_netto, cena_sprzedazy_netto, vat) values(");
		StringBuilder addToProducts = new StringBuilder();
		addToProducts.append("insert into produkty(kod_kreskowy, nazwa, stan_biezacy, kategoria) values(");
		
		System.out.println("kod kreskowy: ");
		String productCode = inputScanner.nextLine();
		addToProducts.append(productCode + ",'");
		createProductFile.append(productCode + ",");
		
		System.out.println("nazwa: ");
		addToProducts.append(inputScanner.nextLine()+"',");
		
		System.out.println("stan: ");
		addToProducts.append(inputScanner.nextLine()+",'");
		
		System.out.println("kategoria: ");
		addToProducts.append(inputScanner.nextLine()+"');");
		
		System.out.println("cena zakupu(np 12.31): ");
		createProductFile.append(inputScanner.nextLine()+",");
		
		System.out.println("cena sprzedazy(np 13.33): ");
		createProductFile.append(inputScanner.nextLine()+",");
		
		System.out.println("vat: ");
		createProductFile.append(inputScanner.nextLine()+");");
		
		try {
			DBCommunicator.executeUpdate(connection, addToProducts.toString()+createProductFile.toString());
			System.out.println("Ok.");
		} catch (SQLException e) {
			System.out.println("Error.");
			e.printStackTrace();
		}
		
		
	}
	
	public void updateProductPrice(Scanner inputScanner){
		StringBuilder update = new StringBuilder("select updateProductPrice(");
		
		System.out.println("kod kreskowy: ");
		update.append(inputScanner.nextLine()+", ");
		
		System.out.println("cena sprzedazy(np 13.33): ");
		update.append(inputScanner.nextLine()+", ");
		
		System.out.println("cena zakupu(np 12.33): ");
		update.append(inputScanner.nextLine()+", ");
		
		System.out.println("vat: ");
		update.append(inputScanner.nextLine()+"); ");
		
		try {
			DBCommunicator.executeUpdate(connection, update.toString());
			System.out.println("Ok.");
		} catch (SQLException e) {
			System.out.println("Error.");
			e.printStackTrace();
		}
	}
}
