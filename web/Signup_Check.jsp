<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.sql.*, Database.DatabaseConnector" %>
<%
    String username = request.getParameter("signupUsername");
    String useremail = request.getParameter("signupEmail");
    String userpassword = request.getParameter("signupPassword");

    String message = " "; // 메시지 변수 추가
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null; // 결과 집합 변수 추가


    try {
        // DB 연결
        con = DatabaseConnector.getConnection();
        if (con != null) {
            message = "데이터베이스에 성공적으로 연결되었습니다.";

            // SQL 쿼리 작성 - 이미 존재하는 이메일과 이름인지 확인
            String checkQuery = "SELECT user_email FROM user WHERE user_email=? OR user_name=?";
            pstmt = con.prepareStatement(checkQuery);
            pstmt.setString(1, useremail);
            pstmt.setString(2, username);
            rs = pstmt.executeQuery();

            // 이미 존재하는 이메일 또는 이름인 경우
            if (rs.next()) {
                message = "이미 존재하는 회원 정보입니다. 로그인해 주세요.";
            } else {
                // 이미 존재하지 않는 경우, 회원가입 진행
                String insertQuery = "INSERT INTO user (user_email, user_name, user_pw) VALUES (?, ?, ?)";
                pstmt = con.prepareStatement(insertQuery);
                pstmt.setString(1, useremail);
                pstmt.setString(2, username);
                pstmt.setString(3, userpassword);

                // 쿼리 실행
                int rowsAffected = pstmt.executeUpdate();

                // 성공 또는 실패에 따라 메시지 설정
                if (rowsAffected > 0) {
                    message = "회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.";
                } else {
                    message = "회원가입 중 오류가 발생했습니다. 다시 시도해 주세요.";
                }
            }
        } else {
            message = "데이터베이스에 연결되지 않았습니다.";
        }
    } catch (SQLException e) {
        // 오류 처리 및 메시지 설정
        message = "회원가입 중 오류가 발생했습니다. 다시 시도해 주세요.";
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
%>

<%
    // 메시지 출력
    out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'index.html';</script>");
%>