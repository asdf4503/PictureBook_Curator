<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.sql.*, Database.DatabaseConnector" %>
<%
    String name = request.getParameter("signupUsername");
    String email = request.getParameter("signupEmail");
    String password = request.getParameter("signupPassword");

    String message = ""; // 메시지 변수 추가
    Connection con = null;
    PreparedStatement pstmt = null;

    try {
        // DB 연결
        con = DatabaseConnector.getConnection();
        if (con != null) {
            message = "데이터베이스에 성공적으로 연결되었습니다.";

            // SQL 쿼리 작성
            String query = "INSERT INTO user_table (name, email, password) VALUES (?, ?, ?)";

            // PreparedStatement 생성
            pstmt = con.prepareStatement(query);

            // 매개변수 설정
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            pstmt.setString(3, password);

            // 쿼리 실행
            int rowsAffected = pstmt.executeUpdate();

            // 성공 또는 실패에 따라 메시지 설정
            if (rowsAffected > 0) {
                message = "회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.";
            } else {
                message = "회원가입 중 오류가 발생했습니다. 다시 시도해 주세요.";
            }
        } else {
            message = "데이터베이스에 연결되지 않았습니다.";
        }
    } catch (SQLException e) {
        // 오류 처리 및 메시지 설정
        message = "회원가입 중 오류가 발생했습니다. 다시 시도해 주세요.";
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
%>

<%
    // 메시지 출력
    out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'index.jsp';</script>");
%>
