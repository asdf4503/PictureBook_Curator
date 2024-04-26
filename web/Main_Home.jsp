<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.sql.*, Database.DatabaseConnector" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="css/styles.css">
    <title>PictureBook Creator</title>
</head>
<body>

<div class="header">
    <div class="title">PictureBook Creator</div>
    <div class="icons">
        <span class="icon search-icon"></span>
        <span class="icon notification-icon"></span>
        <span class="icon settings-icon"></span>
    </div>
</div>
<!-- HTML -->
<div class="sorting-tabs">
    <div class="tab">날짜</div>
    <div class="tab">이름</div>
    <div class="tab">유형</div>
</div>

<div class="main-content">
    <div class="add-book">+</div>
</div>

<div id="addBookModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <form id="bookForm">
            <label for="bookCover">책 표지:</label>
            <input type="file" id="bookCover" accept="image/*" onchange="previewCover(this.files)">
            <div id="coverPreview"></div><br>
            <label for="bookContent">책 내용:</label>
            <input type="file" id="bookContent" accept="image/*" multiple onchange="previewContent(this.files)">
            <div id="contentPreview"></div><br>
            <button type="submit">책 추가</button>
        </form>
    </div>
</div>

<%
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
            String query = "SELECT book_name FROM book WHERE user_id = ?";

            // PreparedStatement 생성
            pstmt = con.prepareStatement(query);

            // 매개변수 설정
            pstmt.setString(1, "1");

            // 쿼리 실행
            ResultSet rs = pstmt.executeQuery();

            String book_name = null;
            if(rs.next()) {
                book_name = rs.getString("book_name");
                session.setAttribute("book_name", book_name); // 사용자 이름을 세션에 저장
            }
        } else {
            Check = 0;
        }
    } catch (SQLException e) {
        // 오류 처리 및 메시지 설정
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
<script>
    const bookContainer = document.querySelector('.main-content');

    // 예시 이미지 파일 경로
    const imagePaths = ['image/<%= session.getAttribute("book_name") %>'];

    // 이미지 파일을 book 클래스에 추가
    imagePaths.forEach(path => {
        const bookDiv = document.createElement('div');
        bookDiv.classList.add('book');

        const img = document.createElement('img');
        img.src = path;

        bookDiv.appendChild(img);
        bookContainer.appendChild(bookDiv);
    });

    //책 추가부분
    const addBookBtn = document.querySelector('.add-book');
    const modal = document.getElementById('addBookModal');
    const closeModal = document.querySelector('.close');

    addBookBtn.addEventListener('click', function() {
        modal.style.display = "block";
    });

    closeModal.addEventListener('click', function() {
        modal.style.display = "none";
    });

    window.addEventListener('click', function(event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
    });

    function previewCover(files) {
        const preview = document.getElementById('coverPreview');
        preview.innerHTML = ''; // 기존 미리보기를 지웁니다.
        if (files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.createElement('img');
                img.src = e.target.result;
                preview.appendChild(img);
            };
            reader.readAsDataURL(files[0]);
        }
    }

    function previewContent(files) {
        const preview = document.getElementById('contentPreview');
        preview.innerHTML = '';
        Array.from(files).forEach(file => {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.createElement('img');
                img.src = e.target.result;
                preview.appendChild(img);
            };
            reader.readAsDataURL(file);
        });
    }

    document.getElementById('bookForm').addEventListener('submit', function(event) {
        event.preventDefault();
        alert('책이 추가되었습니다!');
        modal.style.display = "none";
    });
</script>
</body>
</html>