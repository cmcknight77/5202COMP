import java.sql.*;
import java.util.Scanner;

public class JavaApp1 {
    private static final Scanner S = new Scanner(System.in);

    private static Connection c = null;

    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            c = DriverManager.getConnection("jdbc:mysql://localhost:3306/books?serverTimezone=GMT", "root", "pass1");

            String choice = "";

            do {
                System.out.println("-- MAIN MENU --");
                System.out.println("1 - Browse ResultSet");
                System.out.println("2 - Invoke Procedure");
                System.out.println("Q - Quit");
                System.out.print("Pick : ");

                choice = S.next().toUpperCase();

                switch (choice) {
                    case "1" : {
                        browseResultSet();
                        break;
                    }
                    case "2" : {
                        invokeProcedure();
                        break;
                    }
                }
            } while (!choice.equals("Q"));

            c.close();

            System.out.println("Bye Bye :)");
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
        }
    }

    private static void browseResultSet() throws Exception {
        Statement s = c.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);

        ResultSet result = s.executeQuery("SELECT loan.no, due\r\n from loan\r\n WHERE ( `return` = null) and (year(due) = YEAR(CURRENT_DATE()))");

        ResultSetMetaData resultSet = result.getMetaData();
        
        int columb = resultSet.getColumnCount();
        
        
        while(result.next()) 
        { for (int i = 1; i<= columb; i++)
        	{
        	if (i > 1) System.out.print(", ");
        	String columbNumber = result.getString(i);
        	System.out.print(resultSet.getColumnName(i) + columbNumber);
        	}
        	
        }
        
    }

    private static void invokeProcedure() throws Exception {
    	
    	try {
    	
    	String isbn = "";
    	String studentNo = "";
    	String Procedure = "{Call new_loan(?,?)}";
    	
    	CallableStatement statement = c.prepareCall(Procedure);
    	
    	System.out.print("Enter isbn");
    	isbn = S.next();
    	System.out.print("Enter student number");
    	studentNo = S.next();
    	
    	statement.setString(1, isbn);
    	statement.setString(2, studentNo);
    	statement.execute();
    	}
    	catch (Exception e) { 		
    		System.out.print("Input invalid");   		
    	}

    	
    }
}
