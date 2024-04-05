<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>회원가입</title>
  <link rel="stylesheet" href="css/login_styles.css">
</head>
<body>
<div class="form-container">
  <form action = "Signup_Check.jsp" method="post" id="signupForm">
    <h2>회원가입</h2>
    <input type="text" id="signupUsername" name="signupUsername" placeholder="이름" required>
    <input type="email" id="signupEmail" name="signupEmail" placeholder="이메일" required>
    <input type="password" id="signupPassword" name="signupPassword" placeholder="비밀번호" required>
    <input type="password" id="signupPasswordConfirm" placeholder="비밀번호 확인" required>
    <button type="submit">회원가입</button>
    <p>이미 회원이신가요? <span id="showLogin" onclick="location.href = 'index.jsp';">로그인</span></p>
  </form>
</div>
</body>
</html>