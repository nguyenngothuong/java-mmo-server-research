# Java MMO Server Architecture Research

Đây là bộ mã nguồn Server game MMO (mô phỏng theo NRO) được chia sẻ với mục đích nghiên cứu kiến trúc hệ thống và học tập lập trình Java/Socket.

## ⚠️ Tuyên bố miễn trừ trách nhiệm (Disclaimer)

*   **Dự án này chỉ nhằm mục đích GIÁO DỤC và NGHIÊN CỨU (Educational Purposes Only).**
*   Tôi **KHÔNG** khuyến khích sử dụng mã nguồn này để mở Server lậu hoặc kinh doanh thương mại dưới bất kỳ hình thức nào.
*   Source code này không bao gồm Client game và dữ liệu người dùng thực tế.

## 📂 Tài liệu kỹ thuật

Tôi đã soạn thảo tài liệu phân tích chi tiết kiến trúc hệ thống và cơ sở dữ liệu tại thư mục `docs`:
*   👉 **[Xem Tài liệu Kiến trúc Hệ thống & Database](docs/Arriety_Architecture.md)**

## 🚀 Hướng dẫn cài đặt nhanh (Docker)

1.  Cài đặt [Docker Desktop](https://www.docker.com/products/docker-desktop).
2.  Chạy lệnh sau để khởi tạo Database:
    ```bash
    docker-compose up -d
    ```
3.  Thông tin kết nối Database:
    *   Host: `localhost`
    *   Port: `3308`
    *   User/Pass: `root` / `root`
    *   Database: `arriety`

---
*Repo được tạo và phân tích bởi AI Assistant.*
