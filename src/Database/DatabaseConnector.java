package Database;

import java.sql.*;

public class DatabaseConnector {
    static Connection con;
    public static Connection getConnection() {
        String url = "jdbc:mysql://localhost:3306/picturebook?&serverTimezone=Asia/Seoul&useSSL=false";
        String userid = "root";
        String pwd = "root";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(url, userid, pwd);
        } catch(ClassNotFoundException e) {
            e.printStackTrace();
        } catch(SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static void main(String args[]) {
        new DatabaseConnector();
    }
}