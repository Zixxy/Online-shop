import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public final class DBCommunicator {
	
	private DBCommunicator(){}
	
	public static String readTable(ResultSet set, int columns) throws SQLException{
		StringBuilder result = new StringBuilder();
		while(set.next()){
			for(int i = 1; i <= columns; ++i)
				result.append(set.getString(i)+" | ");
		}
		return result.toString();
	}
	
	public static ResultSet executeQuery(Connection connection, String query) throws SQLException{
		PreparedStatement prepared = connection.prepareStatement(query);
		return prepared.executeQuery();
	}
}
