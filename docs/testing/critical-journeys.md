# Hành trình E2E full-stack

Các hành trình chạy trên ứng dụng thật: Storefront hoặc CMS + Backend + PostgreSQL + Redis thật, provider ngoài là stub có ký chữ ký thật. Đây là lớp duy nhất chứng minh cả hệ thống làm đúng; các biên và nhánh lỗi chi tiết thuộc tầng thấp hơn, không lặp ở đây.

E2E giao diện trong từng app (Playwright với API mock) vẫn giữ cho phần UI; chúng không thay các hành trình này.

## Danh sách

| ID  | Hành trình                                                                            | Kết quả phải kiểm (qua API hoặc DB, không chỉ UI)                                                                    | Luật                            | Trạng thái                    |
| --- | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------- | ----------------------------- |
| J0  | Khách vãng lai xem danh mục → trang Sản phẩm → chọn màu, size                         | Chỉ Sản phẩm `active`; giá hiển thị bằng Giá áp dụng từ Backend; Sản phẩm hết hàng có nhãn và không thêm giỏ được    | BR-CAT-07, BR-CAT-08, BR-PRC-03 | Chạy được                     |
| J1  | Khách vãng lai thêm Biến thể vào giỏ → Tính thử → đặt đơn COD (bấm đặt hai lần)       | Đúng 1 Order `PLACED`; Tồn kho giảm đúng số lượng và thành Hàng chờ xuất; 1 email "Đặt đơn thành công" trong Mailpit | T2, BR-INV-04, BR-NTF-01        | Chờ Storefront nối API        |
| J2  | Giá hoặc tồn kho đổi giữa Tính thử và đặt đơn                                         | Không tạo Order; Storefront hiện Tính thử mới hoặc Biến thể thiếu và số còn lại; đặt lại thì thành công              | BR-ORD-07, BR-INV-06, BR-CRT-04 | Chờ Storefront nối API        |
| J3  | Đặt đơn có Voucher %                                                                  | Tổng hiển thị = tổng Backend lưu; lượt Voucher tăng 1; phân bổ trên Dòng đơn hàng có tổng bằng số giảm               | BR-ORD-01, BR-ORD-02, BR-VCH-10 | Chờ Storefront nối API        |
| J4  | Khách vãng lai có giỏ → đăng nhập Tài khoản đã có giỏ                                 | Giỏ được gộp, Biến thể trùng cộng dồn nhưng không vượt Số lượng bán được                                             | BR-CRT-03                       | Chờ Storefront nối API        |
| J5  | Staff xác nhận → đóng gói đơn trên CMS; Staff huỷ một đơn khác có lý do               | Trạng thái đúng T6, T8; đơn huỷ trả Hàng chờ xuất về Tồn kho và trả lượt Voucher                                     | T6, T7, T8                      | Chưa build (task 33)          |
| J6  | Đặt đơn online → VNPay thất bại → thử lại bằng MoMo → stub gửi IPN thành công hai lần | Đúng 1 Payment thành công, Order `PLACED`, Giữ hàng chuyển thành trừ Tồn kho; IPN lặp không tạo thêm tác động        | T1, T3, BR-PAY-01–03            | Chưa build (task 29)          |
| J7  | Người mua B mở đơn của A; Staff không có quyền gọi hành động Admin trên CMS           | Backend trả 404/403; không lộ dữ liệu; không có thay đổi nào trong DB                                                | US-401, `02-actors-permissions` | Chạy được một phần (phần CMS) |
| J8  | Staff bàn giao → stub GHN tạo Vận đơn → báo đã giao                                   | `SHIPPING` rồi `DELIVERED`; Hàng chờ xuất bị xoá; email "Đang giao", "Đã giao"                                       | T10, T11, BR-SHP-05, BR-INV-10  | Chưa build (task 32)          |
| J9  | Đơn đã giao → Staff ghi nhận Đổi trả → Chấp nhận một phần → ghi nhận Hoàn tiền        | Số hoàn đúng BR-RET-07; chỉ phần chọn nhập lại được cộng Tồn kho; đơn chưa `COMPLETED` khi yêu cầu còn mở            | BR-RET-07, BR-RET-08, BR-INV-08 | Chưa build (task 34)          |

"Chờ Storefront nối API": giỏ, checkout và auth của Storefront hiện vẫn chạy qua MSW (theo `docs/storefront/overview.md` ngày 2026-11-27). Hành trình được bật khi Storefront chuyển phần đó sang API thật.

## Thiết kế runner

- **Vị trí**: thư mục `e2e/` của repo workspace, một project Playwright riêng; không đặt trong repo ứng dụng nào vì hành trình đi qua nhiều ứng dụng ([ADR 0003](../adr/0003-full-stack-e2e-in-workspace.md)).
- **Khởi động**: script khởi động Redis, Mailpit, Backend (`DATABASE_URL` trỏ `fashion_store_e2e`), stub provider (script test của Backend, vì Backend sở hữu code ký), rồi Storefront và CMS ở chế độ build production, tắt MSW.
- **Dữ liệu**: `prisma migrate reset --force` + `db:seed` một lần mỗi lần chạy; mỗi test tự tạo dữ liệu của mình (Biến thể, Voucher, Tài khoản) qua API Admin, với mã duy nhất theo test.
- **Thời gian**: test cần mốc thời gian (hết Giữ hàng, hết link thanh toán, hết hạn Đổi trả) tua qua endpoint `Clock` chỉ bật trong môi trường test của Backend; endpoint này không tồn tại ở build production.
- **Locator**: theo role, label hoặc `data-testid`; không theo class CSS. Không `waitForTimeout`; chờ theo trạng thái UI hoặc API.
- **Khi fail**: lưu trace, video, screenshot và log Backend làm artifact.
- **Song song**: mỗi worker dùng dữ liệu riêng nên chạy song song an toàn; test đồng thời (hai người mua món cuối) không thuộc lớp này mà thuộc integration của Backend.

## Quy tắc thêm hành trình

Chỉ thêm khi hành trình đó bảo vệ một rủi ro mà tầng thấp hơn không bắt được (lỗi tích hợp giữa các ứng dụng hoặc với provider). Tổng số hành trình nên dưới 12. Mọi biến thể dữ liệu (các loại Voucher, các biên số lượng) thuộc unit hoặc API test.
