import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;


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
				"select * from zamowienia where zrealizowane = false;");
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

	public void realizeOrder(int order, String payment_form) throws SQLException{
		try {
			DBCommunicator.execute(connection, 
					"BEGIN; select " + "create_invoice("+Integer.toString(order)+", '" + payment_form + "');" +
					"select " + "execute_order(" + Integer.toString(order)+ "); " + "COMMIT;");
			
		} catch (SQLException e) {
			try {
				connection.rollback();
			} catch (SQLException e1) {}
			throw e;
		}
	}
}
