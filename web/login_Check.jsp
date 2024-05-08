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
    ResultSet rs = null;
    int userId = 0;

    try {
        // DB 연결
        con = DatabaseConnector.getConnection();
        if (con != null) {
            message = "데이터베이스에 성공적으로 연결되었습니다.";

            // SQL 쿼리 작성
            String query = "SELECT user_id FROM user WHERE user_email = ? AND user_pw = ?";

            // PreparedStatement 생성
            pstmt = con.prepareStatement(query);

            // 매개변수 설정
            pstmt.setString(1, useremail);
            pstmt.setString(2, userpassword);

            // 쿼리 실행
            rs = pstmt.executeQuery();

            // user_id 얻기
            if (rs.next()) {
                userId = rs.getInt("user_id");
                message = "로그인 되었습니다. 메인 페이지로 이동합니다.";
            } else {
                message = "로그인 실패하였습니다. 다시 시도해 주세요.";
            }
        } else {
            message = "데이터베이스에 연결되지 않았습니다.";
        }
    } catch (SQLException e) {
        // 오류 처리 및 메시지 설정
        message = "로그인 실패하였습니다. 다시 시도해 주세요.";
        e.printStackTrace(); // 또는 로그에 오류를 기록합니다.
    } finally {
        // ResultSet, PreparedStatement, Connection 닫기
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
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

    // user_id가 0보다 큰 경우에만 세션에 저장
    if (userId > 0) {
        session.setAttribute("user_id", userId);
    }

    // 로그인 성공 여부에 따라 페이지 이동 및 메시지 출력
    if (userId > 0) {
        out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'Main_Home.jsp';</script>");
    } else {
        out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'index.html';</script>");
    }
%>
