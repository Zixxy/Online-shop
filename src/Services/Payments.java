package Services;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;


public class Payments {
	private Connection connection;
	
	public Payments(Connection connection){
		this.connection = connection;
	}
	
	public String selectPayments() throws SQLException{
		ResultSet table = DBCommunicator.executeQuery(connection, "select * from payments;");
		if (!table.isBeforeFirst() ) {    
			System.err.println("No data"); 
			return null;
		}
		return DBCommunicator.readTable(table, 7);	
	}
	
	public int payForDelivery(int delivery) throws SQLException{
		return DBCommunicator.executeUpdate(connection, "update dostawy set uregulowane = true where id_dostawy = " + Integer.toString(delivery) +";");
	}
	
	public int payForDelivery(String delivery) throws SQLException{
		return DBCommunicator.executeUpdate(connection, "update dostawy set uregulowane = true where id_dostawy = " + delivery +";");
	}
}
