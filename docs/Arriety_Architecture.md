# Tài liệu Kiến trúc Hệ thống & Cơ sở dữ liệu Arriety (NRO Server)

Tài liệu này phân tích chi tiết kiến trúc dữ liệu của source game Arriety (dựa trên nền tảng NRO/Dragonboy), nhằm mục đích nghiên cứu và hiểu rõ cách vận hành của một Game Server MMO cổ điển.

## 1. Tổng quan Kiến trúc (High-Level Architecture)

Hệ thống sử dụng mô hình **Client-Server** truyền thống với cơ sở dữ liệu quan hệ (RDBMS). Tuy nhiên, cách thiết kế Schema mang đậm phong cách tối ưu hiệu năng cho Game Real-time.

*   **Core Server:** Java (xử lý logic, socket, luồng game).
*   **Database:** MySQL / MariaDB.
*   **Mô hình dữ liệu:** Hybrid (Lai tạo).
    *   **Phần Quan hệ (Relational):** Dùng cho quản lý tài khoản, bang hội, và dữ liệu tĩnh (Templates).
    *   **Phần Document (NoSQL-like):** Dùng cho dữ liệu nhân vật (Player). Dữ liệu phức tạp được serialize thành chuỗi JSON/Text và lưu vào một cột duy nhất để tối ưu tốc độ đọc/ghi (I/O).

---

## 2. Phân tích Chi tiết Database Schema

### A. Quản lý Tài khoản (Authentication & Economy)

Bảng `account` đóng vai trò cổng gác và quản lý tài sản thực.

| Cột Quan trọng | Kiểu dữ liệu | Giải thích |
| :--- | :--- | :--- |
| `id` | INT | Định danh duy nhất của tài khoản. |
| `username` / `password` | VARCHAR | Thông tin đăng nhập. |
| `ban` | SMALLINT | Trạng thái khóa (1: khóa, 0: hoạt động). |
| `vnd` / `coin` | INT | **Ví tiền chung**. Tiền nạp được lưu ở đây, không nằm trong nhân vật. Cho phép dùng chung tiền cho nhiều server/nhân vật khác nhau. |
| `active` | INT | Trạng thái kích hoạt tài khoản. |

### B. Dữ liệu Nhân vật (Player) - Trái tim của hệ thống

Bảng `player` là nơi chứa 90% dữ liệu biến động của game. Thay vì chuẩn hóa (Normalization) thành nhiều bảng con (`player_items`, `player_skills`...), hệ thống sử dụng kỹ thuật **"Blobbing"** (lưu cục dữ liệu).

**Cấu trúc đặc biệt:**

| Cột | Dạng lưu trữ | Giải thích & Ví dụ |
| :--- | :--- | :--- |
| `data_point` | JSON Array (Text) | Lưu chỉ số cơ bản. Thứ tự index cực kỳ quan trọng.<br>Ví dụ: `[1000, 500, 100]` tương ứng `[HP, MP, Sức đánh]`. |
| `items_body` | JSON Array (Text) | Danh sách trang bị đang mặc trên người. |
| `items_bag` | JSON Array (Text) | Danh sách vật phẩm trong hành trang. |
| `skills` | JSON Array (Text) | Danh sách kỹ năng đã học. |
| `data_task` | JSON Array (Text) | Tiến độ nhiệm vụ hiện tại (ID nhiệm vụ, index bước đi, số lượng quái đã diệt). |

**Tại sao thiết kế như vậy?**
*   **Ưu điểm:**
    *   **Tốc độ Load cực nhanh:** Khi người chơi Login, Server chỉ cần 1 câu lệnh `SELECT * FROM player WHERE id = ...`. Toàn bộ dữ liệu nhân vật được load vào RAM ngay lập tức. Không tốn chi phí `JOIN` nhiều bảng.
    *   **Linh hoạt (Flexibility):** Khi Game Dev muốn thêm một thuộc tính mới cho Item (ví dụ: dòng chỉ số mới), họ chỉ cần sửa code Java để đọc/ghi thêm trường đó vào chuỗi JSON. Không cần `ALTER TABLE` database (việc này rất rủi ro với DB lớn).
*   **Nhược điểm:**
    *   **Khó Query:** Không thể dùng SQL để tìm kiếm chi tiết. Ví dụ: *Không thể* `SELECT * FROM player WHERE items_bag LIKE '%Áo Thần Linh%'` một cách chính xác và hiệu quả. Việc lọc dữ liệu phải thực hiện bằng Tool riêng (load hết lên rồi lọc bằng code).

### C. Dữ liệu Tĩnh (Game Templates / Static Data)

Đây là bộ "Luật" và "Tài nguyên" của thế giới game. Cả Client và Server đều phải hiểu chung các ID này.

#### 1. Map Template (`map_template`)
Định nghĩa các bản đồ trong game.
*   **Sample Data:**
    ```sql
    (0, 'Làng Aru', 12, 12, '[...]', '["Làng Aru",1224,408...]', '[[0,1,100,780,432]...]')
    ```
*   **Giải thích:**
    *   **Waypoints:** Định nghĩa các cổng dịch chuyển (tọa độ X, Y) để sang map khác.
    *   **Mobs:** Danh sách quái vật sinh ra tại map này (Loại quái, Máu, Tọa độ spawn).
    *   **NPCs:** Các nhân vật NPC đứng trong map.

#### 2. Item Template (`item_template`)
Từ điển định nghĩa vật phẩm.
*   **Sample Data:**
    ```sql
    (0, 0, 0, 'Áo vải 3 lỗ', 'Giúp giảm sát thương', 390, 14, ...)
    ```
*   **Giải thích:**
    *   Kết nối giữa `id` vật phẩm và `icon_id` (hình ảnh hiển thị ở Client).
    *   Chứa các thông số tĩnh: Sức mạnh yêu cầu, Tỷ lệ rơi, Giá bán shop.

#### 3. Mob Template (`mob_template`)
Từ điển định nghĩa quái vật.
*   **Sample Data:**
    ```sql
    (1, 1, 'Khủng long', 200, 33, 1, ...)
    ```
*   **Giải thích:**
    *   Tên quái, HP gốc, tốc độ di chuyển, loại đạn bắn ra.

### D. Hệ thống Bang hội (`clan_sv1`, `clan_sv2`)

Hệ thống hỗ trợ nhiều máy chủ (Server partitions) nên có các bảng Clan riêng biệt.
*   Dữ liệu thành viên (`members`) cũng được lưu dạng chuỗi danh sách ID `[id1, id2, id3]`. Khi server khởi động, nó sẽ load danh sách này và map vào các Object Player đang online.

---

## 3. Phân tích Kỹ thuật chuyên sâu

### Vấn đề JSON trong Database
*   **Thực tế:** Mặc dù MySQL/MariaDB hiện đại đã hỗ trợ kiểu dữ liệu `JSON` native, nhưng source code này sử dụng kiểu `TEXT` (String).
*   **Quy trình xử lý:**
    1.  **DB:** Lưu trữ chuỗi ký tự vô tri (Raw String).
    2.  **Server (Java):**
        *   *Load:* Đọc String -> Parse (GSON/Jackson/Custom Parser) -> Java Object (Inventory, Skill List).
        *   *Save:* Java Object -> Serialize -> String -> Update vào DB.
*   **Lợi ích:** Độc lập với công nghệ Database. Có thể chuyển từ MySQL sang SQL Server hay SQLite mà không cần sửa đổi Schema, chỉ cần DB đó hỗ trợ kiểu Text dài.

### Đồng bộ Client - Server
*   Dữ liệu trong `*_template` tables cực kỳ quan trọng.
*   Client game thường chứa một bản copy của dữ liệu này (trong file cache hoặc resource code) để hiển thị hình ảnh đúng với ID item.
*   Nếu thêm Item mới vào DB (Server) mà không update Client -> Lỗi hiển thị (Item null, hoặc crash game).

---

## 4. Kết luận

Kiến trúc của Arriety/NRO là một ví dụ điển hình của **Game Server Development** giai đoạn trước:
1.  **Hiệu năng là số 1:** Hy sinh tính toàn vẹn quan hệ (Relational Integrity) để đổi lấy tốc độ I/O và giảm tải CPU cho Database.
2.  **Logic dồn về App Server:** Database chỉ là nơi "dump" dữ liệu, mọi logic tính toán, validate, quan hệ đều do code Java xử lý.

Đây là mô hình rất tốt để học hỏi về cách tối ưu hóa dữ liệu cho các hệ thống Real-time có lượng tương tác lớn (High Concurrency).

## 5. Phụ lục: Danh sách & Chức năng các Bảng (Tables)

Tổng cộng hệ thống có 41 bảng, được chia thành các nhóm chức năng sau:

### 1. Nhóm Dữ liệu Người dùng (User Data)
*   `account`: Tài khoản đăng nhập, mật khẩu, số dư tiền nạp (VND/Coin).
*   `player`: Thông tin nhân vật (chỉ số, hành trang, kỹ năng...).
*   `clan_sv1`: Dữ liệu Bang hội cho Server 1.
*   `clan_sv2`: Dữ liệu Bang hội cho Server 2.
*   `comment`: Lưu trữ bình luận.
*   `post_question`: Câu hỏi/Bài đăng hỗ trợ.
*   `giftcode`: Mã quà tặng.

### 2. Nhóm Cấu hình Game (Game Templates/Config)
*   `map_template`: Danh sách bản đồ, quái, NPC.
*   `mob_template`: Thông số quái vật (HP, Exp, Damage).
*   `npc_template`: Thông tin NPC (Tên, hình ảnh, hội thoại).
*   `item_template`: Danh sách vật phẩm.
*   `item_option_template`: Các dòng chỉ số (option) của trang bị.
*   `skill_template`: Danh sách kỹ năng.
*   `nclass`: Hệ phái (Trái Đất, Namếc, Xayda).
*   `intrinsic`: Nội tại nhân vật.
*   `task_main_template`, `task_sub_template`, `side_task_template`: Hệ thống nhiệm vụ.
*   `dhvt_template`: Cấu hình Đại Hội Võ Thuật.
*   `radar`: Dữ liệu Radar.

### 3. Nhóm Cửa hàng & Kinh tế (Shop & Economy)
*   `shop`, `tab_shop`: Cấu hình cửa hàng và danh mục.
*   `item_shop`: Vật phẩm bán trong shop.
*   `item_shop_option`: Chỉ số đồ shop.
*   `type_sell_item_shop`: Loại tiền tệ thanh toán.
*   `naptien`, `recharge_card`: Log và cấu hình nạp tiền.

### 4. Nhóm Tài nguyên & Hiển thị (Resources)
*   `part`: Định nghĩa bộ phận cơ thể (Head, Body, Leg).
*   `head_avatar`: Avatar đại diện.
*   `flag_bag`: Cờ đeo lưng.
*   `bg_item_template`: Vật phẩm nền.
*   `img_by_name`: Mapping tên ảnh - ID.
*   `small_version`: Quản lý phiên bản tài nguyên.
*   `caption`: Phụ đề/Thông báo.

### 5. Nhóm Log & Hệ thống (System & Logs)
*   `history_transaction`, `history_gold`, `history_receive_goldbar`, `history_event`: Các bảng log lịch sử.
*   `token`: Token xác thực.
*   `type_item`, `type_map`: Bảng phân loại danh mục.
