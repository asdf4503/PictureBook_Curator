<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="Database.DatabaseConnector" %>
<%
    String useremail = request.getParameter("loginEmail");
    String userpassword = request.getParameter("loginPassword");

    String message = " ";
    Connection con = null;
    PreparedStatement pstmt = null;
    int Check = 0;

    try {
        // DB 연결
        con = DatabaseConnector.getConnection();
        if (con != null) {
            message = "데이터베이스에 성공적으로 연결되었습니다.";

            // SQL 쿼리 작성
            String query = "SELECT user_email, user_pw FROM user WHERE user_email = ? AND user_pw = ?";

            // PreparedStatement 생성
            pstmt = con.prepareStatement(query);

            // 매개변수 설정
            pstmt.setString(1, useremail);
            pstmt.setString(2, userpassword);

            // 쿼리 실행
            ResultSet rs = pstmt.executeQuery();

            // 성공 또는 실패에 따라 메시지 설정
            if (rs.next()) {
                message = "로그인 되었습니다. 메인 페이지로 이동합니다.";
                Check = 1;
            } else {
                message = "로그인 실패하였습니다. 다시 시도해 주세요.";
                Check = 0;
            }
        } else {
            message = "데이터베이스에 연결되지 않았습니다.";
            Check = 0;
        }
    } catch (SQLException e) {
        // 오류 처리 및 메시지 설정
        message = "로그인 실패하였습니다. 다시 시도해 주세요.";
        Check = 0;
        e.printStackTrace(); // 또는 로그에 오류를 기록합니다.
    } finally {
        // PreparedStatement 및 Connection 닫기
        if (pstmt != null) {
            try {
                pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (con != null) {
            try {
                con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    if(Check > 0) {
        // 메시지 출력
        out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'Main_Home.jsp';</script>");
    } else {
        // 메시지 출력
        out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'index.html';</script>");
    }
%>
