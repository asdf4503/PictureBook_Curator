<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="Database.DatabaseConnector" %>
<%
    String email = request.getParameter("loginEmail");

    Connection con = null;

    //DB 연결
    con = DatabaseConnector.getConnection();


%>