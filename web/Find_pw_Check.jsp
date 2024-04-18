<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="Database.DatabaseConnector" %>
<%@ page import="java.util.Properties" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="java.util.Random" %>

<%
    String name = request.getParameter("findUsername");
    String email = request.getParameter("findEmail");

    String message = " ";
    Connection con = null;
    PreparedStatement pstmt = null;
    int check = 0;

    try {
        // DB 연결
        con = DatabaseConnector.getConnection();
        if (con != null) {
            message = "데이터베이스에 성공적으로 연결되었습니다.";

            // SQL 쿼리 작성
            String query = "SELECT user_email, user_name FROM user WHERE user_email = ? AND user_name = ?";

            // PreparedStatement 생성
            pstmt = con.prepareStatement(query);

            // 매개변수 설정
            pstmt.setString(1, email);
            pstmt.setString(2, name);

            // 쿼리 실행
            ResultSet rs = pstmt.executeQuery();

            // 성공 또는 실패에 따라 메시지 설정
            if (rs.next()) {
                // 6자리 난수 생성
                Random random = new Random();
                int randomNumber = 100000 + random.nextInt(900000); // 100000부터 999999 사이의 난수 생성
                String verificationCode = String.valueOf(randomNumber);

                // JavaMail을 사용하여 메일 보내기
                final String fromEmail = "epdlwl515@naver.com"; // 발신자 Naver 이메일
                final String password = "FMQYSMYMK224"; // 발신자 Naver 비밀번호

                // SMTP 서버 설정 (Naver의 경우)
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.naver.com");
                props.put("mail.smtp.port", "465");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.ssl.enable", "true");

                // 인증 정보 설정
                Authenticator auth = new Authenticator() {
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(fromEmail, password);
                    }
                };

                // 세션 생성 및 메시지 설정
                Session mailSession = Session.getInstance(props, auth);
                Message emailMessage = new MimeMessage(mailSession);
                emailMessage.setFrom(new InternetAddress(fromEmail));
                emailMessage.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
                emailMessage.setSubject("비밀번호 재설정 인증 코드입니다.");
                emailMessage.setText("비밀번호 재설정을 위한 인증 코드는 다음과 같습니다: " + verificationCode); // 이메일 본문

                // 메일 전송
                Transport.send(emailMessage);

                // 난수를 DB에 저장
                query = "UPDATE user SET user_pw = ? WHERE user_email = ? AND user_name = ?";
                pstmt = con.prepareStatement(query);
                pstmt.setString(1, verificationCode);
                pstmt.setString(2, email);
                pstmt.setString(3, name);
                int rowsUpdated = pstmt.executeUpdate(); // UPDATE 쿼리 실행

                if (rowsUpdated > 0) {
                    // DB에 저장 성공
                    message = "비밀번호 재설정을 위한 인증 코드가 이메일로 전송되었습니다.";
                    check = 1;
                } else {
                    // DB에 저장 실패
                    message = "오류가 발생했습니다.";
                }
            } else {
                message = "정보가 일치하지 않습니다. 다시 시도해 주세요.";
                check = 0;
            }
        } else {
            message = "데이터베이스에 연결되지 않았습니다.";
            check = 0;
        }
    } catch (SQLException e) {
        // 오류 처리 및 메시지 설정
        message = "데이터베이스 작업 중 오류가 발생했습니다.";
        check = 0;
        e.printStackTrace(); // 또는 로그에 오류를 기록합니다.
    } catch (MessagingException e) {
        // 메일 전송 오류 처리
        message = "메일 전송에 실패하였습니다.";
        check = 0;
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
        out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'verificationCode.html';</script>");
    } else {
        // 메시지 출력
        out.println("<script type='text/javascript'>alert('" + message + "'); window.location.href = 'Find_pw.html';</script>");
    }
%>
