# Ma trận trách nhiệm Backend, CMS và Storefront

Mỗi dòng nói tầng nào bảo vệ kiểu lỗi nào cho một luật. Backend là nguồn sự thật cho mọi luật nghiệp vụ; CMS và Storefront chỉ phục vụ trải nghiệm và hiển thị đúng điều Backend trả. Cột E2E chỉ ghi khi luật nằm trong một [hành trình quan trọng](critical-journeys.md).

## Mua hàng (Storefront ↔ Backend)

| Luật                               | Storefront                                                         | Backend                                                                               | E2E |
| ---------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------- | --- |
| BR-CAT-07, BR-CAT-08               | Hiển thị nhãn "Hết hàng", vô hiệu nút thêm giỏ                     | Chỉ trả Sản phẩm `active`; từ chối thêm Biến thể hết hàng                             | J0  |
| BR-CRT-05 (tối đa 10)              | Chặn stepper ở 10, báo lỗi Backend trả                             | Từ chối số lượng > 10, 0 hoặc âm                                                      | —   |
| BR-CRT-04 (giá đổi)                | Thông báo giá mới                                                  | Giỏ luôn dùng Giá áp dụng hiện tại                                                    | J2  |
| BR-CRT-03 (gộp giỏ)                | Làm mới giỏ sau đăng nhập, không ghi đè bằng state cũ              | Gộp, cộng dồn, không vượt Số lượng bán được                                           | J4  |
| BR-ORD-07 (khớp Tính thử)          | Hiện Tính thử mới khi Backend từ chối; không tự tính tổng          | Tính lại toàn bộ, từ chối khi khác Tính thử kể cả cùng tổng                           | J2  |
| BR-ORD-01, BR-VCH-10               | Hiển thị đúng số Backend trả, định dạng VND                        | Tính bằng số nguyên, làm tròn theo luật                                               | J3  |
| BR-ORD-09 (tổng > 0)               | Hiển thị lỗi                                                       | Từ chối, không tạo Order, Payment, Giữ hàng, lượt Voucher                             | —   |
| BR-INV-06 (thiếu hàng)             | Báo Biến thể nào thiếu, còn bao nhiêu; cho sửa giỏ                 | Không tạo đơn; trả danh sách thiếu                                                    | J2  |
| BR-INV-02 (hai người mua món cuối) | Hiển thị kết quả Backend                                           | Đúng một đơn thành công, Số lượng bán được không âm                                   | —   |
| Double submit đặt đơn              | Khoá nút khi đang gửi, gửi kèm idempotency key                     | Cùng key + cùng payload → một đơn; cùng key + khác payload → từ chối                  | J1  |
| BR-PAY-06 (hạn mức COD)            | Ẩn hoặc vô hiệu COD khi vượt mức, giải thích lý do                 | Từ chối COD vượt mức                                                                  | —   |
| BR-PAY-01 (đổi Cổng khi thử lại)   | Cho chọn VNPay/MoMo mỗi lần trả, hiện thời gian còn lại            | Không tạo link mới từ phút 7; link hết hạn phút 10                                    | J6  |
| BR-PAY-02 (Return URL)             | Trang kết quả chỉ đọc trạng thái từ Backend, không tự báo "đã trả" | Chỉ xác nhận qua IPN hoặc Đối soát                                                    | J6  |
| BR-PAY-03, BR-PAY-04, BR-PAY-05    | —                                                                  | IPN lặp xử lý một lần; sai số tiền không xác nhận và tự tạo Hoàn tiền                 | J6  |
| BR-ORD-04 (địa chỉ 2 cấp)          | Validate form, focus lỗi đầu tiên, chọn tỉnh → phường/xã           | Validate schema và mã hành chính                                                      | J1  |
| BR-SHP-02 (phí dự phòng)           | Hiển thị phí Backend trả, không tự đặt phí                         | GHN lỗi → phí dự phòng + Cờ cần xử lý                                                 | —   |
| US-401, US-402 (xem đơn)           | Ẩn đơn không thuộc phiên                                           | Ownership: Người mua chỉ đọc đơn của mình; Khách vãng lai theo Mã đơn + số điện thoại | J7  |
| T5, T7 (Người mua tự huỷ)          | Chỉ hiện nút huỷ khi trạng thái cho phép                           | Từ chối huỷ từ `PACKING` trở đi                                                       | —   |
| BR-NTF-01 (email)                  | —                                                                  | Gửi đúng sự kiện, không gửi cho đơn online chưa thanh toán, không gửi trùng           | J1  |

## Back-office (CMS ↔ Backend)

| Luật                                                        | CMS                                                                  | Backend                                                      | E2E |
| ----------------------------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------ | --- |
| Ma trận quyền Staff/Admin (`02-actors-permissions` mục 3.2) | Ẩn hoặc vô hiệu hành động theo `permissions` của `/auth/me`          | Enforce quyền từng endpoint; 403 khi thiếu quyền             | J7  |
| Huỷ đơn bắt buộc lý do (T7, T9, T14)                        | Form bắt buộc lý do, hộp xác nhận thao tác phá huỷ                   | Từ chối khi thiếu lý do hoặc chuyển trạng thái không hợp lệ  | J5  |
| T9 khi Vận đơn đang tạo (mục 4.5)                           | Hiển thị lỗi và trạng thái Vận đơn                                   | Từ chối huỷ khi Vận đơn `creating`/`creation_unknown`        | —   |
| BR-INV-11, BR-INV-12 (điều chỉnh, Kiểm kê)                  | Hiện số tối đa giảm được từ lỗi Backend                              | Từ chối giảm vượt Số lượng bán được; ghi lịch sử (BR-INV-09) | —   |
| BR-PRC-05, BR-PRC-06 (Giá khuyến mãi)                       | Khoá trường không được sửa theo trạng thái                           | Từ chối sửa trái luật                                        | —   |
| BR-VCH-11 (sửa Voucher đã dùng)                             | Khoá mã và các trường không được sửa                                 | Từ chối sửa hoặc xoá trái luật                               | —   |
| BR-CAT-09 (không xoá cứng)                                  | Chỉ hiện "Ngừng bán" cho Sản phẩm đã có đơn                          | Từ chối xoá, chỉ cho `archived`                              | —   |
| BR-REF-03, BR-REF-06 (ghi nhận Hoàn tiền)                   | Bắt buộc mã giao dịch hoàn, chặn bấm hai lần                         | Một yêu cầu cho mỗi thao tác; tổng không vượt số đã nhận     | J9  |
| BR-RET-08 (Chấp nhận theo dòng)                             | Nhập số lượng 0 tới số gửi trả, chọn nhập lại Tồn kho                | Tính hoàn lũy kế BR-RET-07, khoá Order khi tính              | J9  |
| Sửa cùng lúc                                                | Hiển thị lỗi xung đột, cho tải lại                                   | Không ghi đè mất cập nhật của người khác                     | —   |
| Phiên hết hạn                                               | Refresh một lần cho nhiều request 401; refresh fail thì về đăng nhập | Refresh rotation, thu hồi phiên                              | —   |

## Hợp đồng

| Rủi ro                                | Ai bảo vệ                                                                      |
| ------------------------------------- | ------------------------------------------------------------------------------ |
| Backend đổi response mà quên OpenAPI  | Backend CI: `openapi:write` + `git diff --exit-code docs/openapi/openapi.json` |
| CMS, Storefront dùng field đã bỏ      | CMS và Storefront CI: `gen:api` + diff client sinh + typecheck                 |
| Breaking Change lọt vào bản phát hành | Luồng Contract Version của workspace (`shared/agents/workspace.md`)            |
| Mapper ở CMS, Storefront hiểu sai     | Unit test mapper với payload lấy từ schema sinh, không viết tay kiểu dữ liệu   |
