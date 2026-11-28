# Lịch chạy, gate và metric

## Lịch chạy

| Giai đoạn | Chạy gì                                                                                                                                                          | Ở đâu                 |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| Local     | Lint, typecheck, unit và component liên quan đến file đổi (`vitest related` hoặc theo thư mục)                                                                   | Máy dev, pre-commit   |
| PR        | Lint, typecheck, toàn bộ unit/component, coverage; Backend: API và integration trên Postgres thật, gồm test đồng thời; E2E giao diện với API mock; contract diff | CI của từng app       |
| Nightly   | E2E full-stack J0–J9 (các hành trình đã chạy được), mutation testing, browser matrix (Chromium, Firefox, WebKit) cho Storefront                                  | CI của repo workspace |
| Release   | Smoke thủ công với sandbox thật của VNPay, MoMo, GHN; xem kết quả nightly gần nhất                                                                               | Thủ công              |

E2E full-stack bắt đầu ở nightly. Khi đã ổn định (không flaky trong 2 tuần liên tục), chuyển J0, J1, J7 thành gate của PR vào `dev` ở Backend và Storefront.

## Gate không bù được bằng điểm

Một gate fail thì không merge (PR) hoặc không release, dù điểm audit cao:

- [ ] Mọi luật P0 đã build có ít nhất một test PASS ở tầng đã chọn trong traceability.
- [ ] Không có lỗi đã biết, chưa xử lý, về tiền, Tồn kho, phân quyền hoặc mất dữ liệu.
- [ ] Test đồng thời của Tồn kho và Voucher PASS (hai người mua món cuối, hai đơn dùng lượt cuối).
- [ ] Idempotency PASS: đặt đơn hai lần, IPN lặp, Hoàn tiền xử lý lại.
- [ ] Không có test flaky chưa xử lý trong bộ P0.
- [ ] Không dùng `skip`, `only` hoặc retry để làm xanh CI; ngoại lệ phải có issue và hạn sửa.
- [ ] Contract diff sạch ở cả ba app.
- [ ] Bằng chứng có commit, môi trường và thời điểm chạy.

## Metric

| Metric                        | Ngưỡng                                      | Ghi chú                                                                                     |
| ----------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Coverage line/branch/function | Sàn 50% cho cả ba app                       | Chỉ là sàn để phát hiện vùng bỏ quên, không phải mục tiêu. Backend bật lại ngưỡng ở task 49 |
| Mutation score                | ≥ 75% trên phạm vi mutation                 | Nightly, không chặn PR                                                                      |
| Luật P0 đã build có test PASS | 100%                                        | Đo từ traceability                                                                          |
| Luật P1 đã build có test PASS | Theo dõi, hướng tới 100%                    |                                                                                             |
| Hành trình full-stack PASS    | 100% các hành trình "Chạy được"             |                                                                                             |
| Flaky rate                    | < 1%, hướng tới 0                           | Flaky = pass/fail khác nhau khi code và dữ liệu không đổi                                   |
| Thời gian CI của PR           | Theo dõi; cảnh báo khi một job vượt 15 phút | Không bỏ test P0 để CI nhanh hơn                                                            |
| Lỗi lọt                       | Theo dõi                                    | Mỗi lỗi lọt có regression test khi khả thi                                                  |

**Phạm vi mutation** (Stryker), chỉ logic tiền và tồn kho của Backend:

- Tính tiền Voucher, phân bổ Voucher về Dòng đơn hàng (BR-VCH-10, BR-ORD-02).
- Giá áp dụng và mức giảm của Giá khuyến mãi (BR-PRC-03, BR-PRC-04).
- Số lượng bán được, Giữ hàng, Hàng chờ xuất (BR-INV-02, BR-INV-05, BR-INV-10).
- Chuyển trạng thái Đơn hàng T1–T14.
- Số tiền Hoàn tiền lũy kế (BR-RET-07) và giới hạn Hoàn tiền (BR-REF-06), khi đã build.

Ví dụ mutant phải bị giết: `available >= quantity` đổi thành `available > quantity` → test đặt đúng bằng Số lượng bán được phải fail.

## N/A và lý do

| Hạng mục                                                            | Trạng thái                   | Lý do                                                                     | Bật lại khi                |
| ------------------------------------------------------------------- | ---------------------------- | ------------------------------------------------------------------------- | -------------------------- |
| Load và stress test (k6)                                            | N/A                          | Chưa có môi trường staging; không chạy tải trên máy dev hay provider thật | Có staging                 |
| Rehearsal migration trên dữ liệu đại diện, backup/restore           | N/A                          | Chưa có dữ liệu production                                                | Có staging hoặc production |
| Chaos testing                                                       | N/A                          | Một instance, chưa có hạ tầng phân tán                                    | Chạy nhiều instance        |
| Pact                                                                | N/A                          | OpenAPI + client sinh + diff đã bảo vệ hợp đồng                           | Có consumer ngoài ba app   |
| Đa tiền tệ, đa Kho, marketplace, subscription                       | N/A                          | Ngoài phạm vi MVP (BR-INV-01: một Kho; giá VND)                           | Phạm vi đổi                |
| OAuth account linking, MFA cho Staff (ACCOUNTS-07, 08 của handbook) | Khoảng trống cần BA xác nhận | Có đăng nhập Google (US-502) nhưng chưa có luật về liên kết hoặc MFA      | BA bổ sung luật            |
| Review sản phẩm, moderation (SEARCH-06, 07)                         | N/A                          | Không có trong phạm vi MVP                                                | Có user story              |
| Unsubscribe marketing (SEARCH-11)                                   | N/A                          | MVP chỉ gửi email giao dịch (BR-NTF-01)                                   | Có email marketing         |
| Import CSV, bulk action (CMS-03, 04 của handbook)                   | N/A                          | Không có user story                                                       | Có user story              |
| Visual regression bằng dịch vụ ngoài (Chromatic, Percy)             | N/A                          | Chưa có ngân sách; dùng screenshot Playwright khi cần                     | Có ngân sách               |
