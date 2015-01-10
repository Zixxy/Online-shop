import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class ExecutorOfOrders {
	private Connection connection;
	
	public ExecutorOfOrders(Connection newConnection){
		connection = newConnection;
	}
	
	public void executeOrder(int number){
		//TODO
	}
	
	public String selectOrders(){
		try {
			ResultSet resultSet = DBCommunicator.executeQuery(connection, "select * from zamowienia;");
			return DBCommunicator.readTable(resultSet, 5);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public String selectUnrealizedOrders(){
		try{
			ResultSet resultSet = DBCommunicator.executeQuery(connection, 
					"select * from zamowienia where zrealizowane = false;");
			return DBCommunicator.readTable(resultSet, 5);
		} catch (SQLException e){
			e.printStackTrace();
		}
		return null;
	}
}
