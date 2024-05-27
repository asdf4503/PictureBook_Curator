package main;

import Database.DatabaseConnector;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "UploadContentServlet", value = "/UploadContentServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class UploadContentServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 세션에서 책 이름과 user_id 가져오기
        HttpSession session = request.getSession();
        String bookName = (String) session.getAttribute("bookName");
        Integer userId = (Integer) session.getAttribute("user_id");
        String coverImage = (String) session.getAttribute("bookCover");

        if (bookName == null || coverImage == null || userId == null) {
            response.sendRedirect("Main_home.jsp");  // 책 이름이나 책 표지가 없으면 메인 페이지로 리다이렉트
            return;
        }

        // 파일 저장 경로 설정
        String savePath = "C:\\Users\\pc\\IdeaProjects\\PictureBook_Curator\\web\\image\\" + bookName +"\\bookContent";
        File fileSaveDir = new File(savePath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdirs();
        }

        // 업로드된 이미지 파일명을 저장할 리스트
        List<String> imageFileNames = new ArrayList<>();

        // 책 내용 이미지 업로드 처리
        int imageCounter = 1; // 이미지 카운터 초기화
        for (Part part : request.getParts()) {
            if (part.getName().startsWith("bookContent") && part.getSize() > 0) {
                String contentFileName = part.getSubmittedFileName();
                saveFile(part, savePath, contentFileName);
                imageFileNames.add(contentFileName);
                imageCounter++;
            }
        }

        // DB에 이미지 정보 저장
        try {
            // 데이터베이스 연결
            Connection con = DatabaseConnector.getConnection();

            // user_id로부터 book_id 검색
            int bookId = getBookId(userId, con);

            // SQL 쿼리 작성
            String query = "INSERT INTO image (book_id, cover_image";

            // 이미지 파일 열에 대한 쿼리 열 추가
            for (int i = 1; i < imageCounter; i++) {
                query += ", image_value_" + i;
            }

            query += ") VALUES (?, ?";

            // 이미지 파일 열에 대한 쿼리 매개변수 추가
            for (int i = 0; i < imageFileNames.size(); i++) {
                query += ", ?";
            }

            query += ")";

            // PreparedStatement 생성 및 매개변수 설정
            PreparedStatement pstmt = con.prepareStatement(query);
            pstmt.setInt(1, bookId); // 책 표지 이미지 파일명을 cover_image에 저장
            pstmt.setString(2, coverImage); // book_id 설정

            // 이미지 파일명에 대한 쿼리 매개변수 설정
            for (int i = 0; i < imageFileNames.size(); i++) {
                pstmt.setString(i + 3, imageFileNames.get(i)); // 이미지 파일명을 해당하는 열에 저장
            }

            // 쿼리 실행
            pstmt.executeUpdate();

            // 자원 해제
            pstmt.close();
            con.close();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error", e);
        }

        // 이미지 파일명 리스트를 request 속성으로 설정
        request.setAttribute("imageFileNames", imageFileNames);

        // JSP 페이지로 포워딩
        RequestDispatcher dispatcher = request.getRequestDispatcher("insert_book.jsp");
        dispatcher.forward(request, response);
    }

    private void saveFile(Part filePart, String savePath, String fileName) throws IOException {
        try (InputStream inputStream = filePart.getInputStream();
             OutputStream outputStream = new FileOutputStream(new File(savePath, fileName))) {
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
        }
    }

    private int getBookId(int userId, Connection con) throws SQLException {
        String query = "SELECT book_id FROM book WHERE user_id = ?";
        PreparedStatement pstmt = con.prepareStatement(query);
        pstmt.setInt(1, userId);
        ResultSet resultSet = pstmt.executeQuery();
        if (resultSet.next()) {
            return resultSet.getInt("book_id");
        } else {
            throw new SQLException("No book found for the given user_id");
        }
    }
}
