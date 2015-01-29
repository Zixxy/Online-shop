package UserCommunication;
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
		connection = DriverManager.getConnection(URL,USER,PASS);
		System.out.println("-------- PostgreSQL "
				+ "JDBC Connection Established ------------");
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
			new UserCommunicator(new Loader().connection).run();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
