import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;



public class Loader {
	private static final String URL = "jdbc:postgresql://localhost:5432/sylwek";
	private static final String USER = "sylwek";
	private static final String PASS = "proste123"; //doesn't matter
	
	private Connection connection;
	
	public Loader() throws SQLException{
		System.out.println("-------- PostgreSQL "
				+ "JDBC Connection Testing ------------");

		PreparedStatement preparedStatement;
		ResultSet result;
		connection = DriverManager.getConnection(URL,USER,PASS);
	}
	
	public void finalize(){
		try {
			connection.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public static void main(String[] args){
		try {
			System.out.print(new OrdersService(new Loader().connection).selectUnrealizedOrders());
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
