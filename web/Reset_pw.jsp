<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="Database.DatabaseConnector" %>

<%
    String password = request.getParameter("resetPassword");
    String passwordConfirm = request.getParameter("resetPasswordConfirm");
    String code = (String) session.getAttribute("verificationCode");

    String message = " "; // 메시지 변수 추가
    Connection con = null;
    PreparedStatement pstmt = null;
    int check = 0;

    if(password.equals(passwordConfirm)) {
        try {
            // DB 연결
            con = DatabaseConnector.getConnection();
            if (con != null) {
                // SQL 쿼리 작성
                String query = "UPDATE user SET user_pw = ? WHERE user_pw = ?";
                // PreparedStatement 생성
                pstmt = con.prepareStatement(query);

                // 매개변수 설정
                pstmt.setString(1, password);
                pstmt.setString(2, code);

                int rowsAffected = pstmt.executeUpdate(); // executeUpdate()로 변경

                // 성공 또는 실패에 따라 메시지 설정
                if (rowsAffected > 0) {
                    message = "비밀번호가 성공적으로 재설정되었습니다.";
                    check = 1;
                } else {
                    message = "비밀번호 재설정에 실패했습니다.";
                    check = 0;
                }

            } else {
                message = "데이터베이스에 연결되지 않았습니다.";
                check = 0;
            }
        } catch (SQLException e) {
            // 오류 처리 및 메시지 설정
            message = "오류가 발생했습니다. 다시 시도해 주세요.";
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

        if(check > 0) {
            // 메시지 출력
            out.println("<script type='text/javascript'>alert('" + message + "');  window.location.href = 'index.html'; </script>");
        } else {
            // 메시지 출력
            out.println("<script type='text/javascript'>alert('" + message + "');  window.location.href = 'Reset_pw.html'; </script>");
        }

    } else {
        message = "비밀번호가 일치하지 않습니다.";
        // 메시지 출력
        out.println("<script type='text/javascript'>alert('" + message + "');  window.location.href = 'Reset_pw.html'; </script>");
    }
%>