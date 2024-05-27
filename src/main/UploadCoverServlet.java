package main;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import Database.DatabaseConnector;

@WebServlet(name = "UploadCoverServlet", value = "/UploadCoverServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class UploadCoverServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 책 이름 가져오기
        String bookName = request.getParameter("bookName");

        // 세션에서 user_id 가져오기
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");

        // 디버깅 메시지
        System.out.println("bookName: " + bookName);
        System.out.println("userId: " + userId);

        // 이미지 파일 업로드 처리
        Part filePart = request.getPart("bookCover");
        String fileName = filePart.getSubmittedFileName();

        // 파일 저장 경로 설정
        String savePath = "C:\\Users\\pc\\IdeaProjects\\PictureBook_Curator\\web\\image\\" + bookName;
        File fileSaveDir = new File(savePath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdir();
        }

        // 파일 저장
        try (InputStream inputStream = filePart.getInputStream();
             OutputStream outputStream = new FileOutputStream(savePath + File.separator + fileName)) {
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
        }

        // DB에 책 정보 저장
        try {
            // 데이터베이스 연결
            Connection con = DatabaseConnector.getConnection();

            // 디버깅 메시지
            System.out.println("Database connection established");

            // SQL 쿼리 작성
            String query = "INSERT INTO book (book_name, user_id) VALUES (?, ?)";

            // PreparedStatement 생성 및 매개변수 설정
            PreparedStatement pstmt = con.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, bookName);
            pstmt.setInt(2, userId);

            // 디버깅 메시지
            System.out.println("Executing query: " + query);
            System.out.println("With parameters: userId = " + userId + ", bookName = " + bookName);

            // 쿼리 실행
            pstmt.executeUpdate();

            // 생성된 book_id 가져오기
            ResultSet generatedKeys = pstmt.getGeneratedKeys();
            int bookId = 0; // 초기값 설정
            if (generatedKeys.next()) {
                bookId = generatedKeys.getInt(1);
            }

            // 자원 해제
            pstmt.close();
            con.close();

            // book_id를 세션에 저장
            session.setAttribute("book_id", bookId);
            System.out.println("세션에 저장된 book_id : " + bookId);

        } catch (SQLException e) {
            // 디버깅 메시지
            System.err.println("Database error: " + e.getMessage());
            throw new ServletException("Database error", e);
        }

        // 파일 이름 목록 생성
        List<String> fileNames = new ArrayList<>();
        fileNames.add(fileName);

        session.setAttribute("bookCover", fileName);
        System.out.println("세션에 저장된 책 표지" + fileName);

        // 파일 이름 목록을 request 속성으로 설정
        request.setAttribute("fileNames", fileNames);

        // 책 이름을 세션 속성으로 설정
        session.setAttribute("bookName", bookName);

        // JSP 페이지로 포워딩
        RequestDispatcher dispatcher = request.getRequestDispatcher("bookContent.html");
        dispatcher.forward(request, response);
    }
}
