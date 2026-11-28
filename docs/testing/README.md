# Chiến lược kiểm thử Fashion Store

Trạng thái: **thiết kế đã duyệt, chưa triển khai** (2026-11-28). Tài liệu này là luật chung cho Backend, CMS và Storefront. Phần riêng của từng ứng dụng nằm trong repo của ứng dụng đó (xem [Bản đồ tài liệu](#bản-đồ-tài-liệu)).

Nguồn: hai bộ handbook `ecommerce-testing-handbook/` và `testing-quality-extension/` trong `be-demo/docs/plan/wayfinding/software-architect-ecommerce/`, áp vào luật nghiệp vụ thật của project (`be-demo/docs/business/`). Handbook chỉ là checklist gợi ý; nguồn yêu cầu là luật của project.

## Nguyên tắc

1. **Yêu cầu bắt đầu từ luật có thật.** Mỗi kịch bản trỏ tới một `BR-*`, một chuyển trạng thái `T1`–`T14` (vòng đời Đơn hàng) hoặc một `US-*`. Kịch bản của handbook không khớp luật nào thì ghi **N/A kèm lý do**, hoặc **Khoảng trống cần BA xác nhận** nếu đó là rủi ro thật. Không tự đặt ra yêu cầu.
2. **Thuật ngữ theo GLOSSARY của project**, không theo handbook: Giữ hàng (không phải reservation), Số lượng bán được, Hàng chờ xuất, Tính thử, Cờ cần xử lý, Đổi trả, Hoàn tiền, Hoàn hàng.
3. **Mức rủi ro theo nhóm luật.** Quyết định tầng test và mức bắt buộc.

   | Mức | Nhóm luật                                                                                                                                                        |
   | --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | P0  | Đặt hàng và tính tiền (`ORD`), Tồn kho (`INV`), Voucher (`VCH`), Giá khuyến mãi (`PRC`), Thanh toán (`PAY`), Hoàn tiền (`REF`), xác thực và phân quyền           |
   | P1  | Giỏ hàng (`CRT`), Danh mục và Sản phẩm (`CAT`, trừ tìm kiếm), Vận chuyển (`SHP`), Đổi trả (`RET`), Doanh thu (`REV`), Thông báo (`NTF`), thao tác Staff trên CMS |
   | P2  | Tìm kiếm và sắp xếp (`BR-CAT-12`, `BR-CAT-13`), bản dịch danh mục, giao diện và nội dung                                                                         |
   | P3  | Trang tĩnh                                                                                                                                                       |

4. **Tầng thấp nhất còn phát hiện được lỗi.** Mỗi tầng bảo vệ một kiểu lỗi khác nhau; cùng một luật ở nhiều tầng chỉ hợp lệ khi mỗi tầng bắt một lỗi khác.

   | Rủi ro                                                          | Tầng                                           |
   | --------------------------------------------------------------- | ---------------------------------------------- |
   | Công thức tiền, làm tròn, phân bổ, điều kiện, chuyển trạng thái | Unit (domain/application)                      |
   | Ràng buộc DB, transaction, rollback, khoá dòng                  | Integration với Postgres thật                  |
   | Quyền, ownership, status, mã lỗi, schema response               | API (Backend `test/**/*.e2e-spec.ts`)          |
   | Hai request cùng lúc, webhook trùng, job chạy song song         | Integration đồng thời trên Postgres thật       |
   | Hiển thị loading/empty/error, chặn double submit, form          | Component (CMS, Storefront)                    |
   | Gọi đúng API, cache, URL, session hết hạn                       | Integration phía FE với HTTP fake              |
   | Lệch hợp đồng Backend ↔ FE                                      | Contract: OpenAPI + client sinh + diff         |
   | Cả hệ thống làm đúng một hành trình                             | E2E full-stack ([J0–J9](critical-journeys.md)) |

5. **Chống over-testing.** Ví dụ BR-VCH-10: unit kiểm mọi biên của công thức; API kiểm Backend có áp công thức và từ chối Voucher sai; integration kiểm hết lượt khi hai đơn dùng cùng lúc; E2E chỉ một đơn có Voucher. Không lặp mọi biên ở UI, API và E2E. Không test getter, DTO, wiring framework, snapshot cả component hay chỉ để tăng coverage.
6. **FE kiểm không thay BE kiểm.** FE ẩn nút, chặn double submit, validate form để phục vụ trải nghiệm; Backend vẫn phải từ chối. Ma trận: [responsibility-matrix.md](responsibility-matrix.md).

## Thiết kế kịch bản

- **Biên**: mỗi ngưỡng kiểm dưới, bằng và trên. Ví dụ Ngưỡng miễn phí ship 500.000đ → 499.999 / 500.000 / 500.001; số lượng tối đa trong giỏ 10 → 10 / 11; hạn Đổi trả đủ 7 × 24 giờ → 1 giây trước và đúng mốc.
- **Bảng quyết định** cho điều kiện kết hợp: Voucher (hiệu lực × đơn tối thiểu × tổng lượt × lượt mỗi Người mua, BR-VCH-04/07), quyền Staff/Admin theo hành động.
- **Chuyển trạng thái**: mọi dòng `T1`–`T14` có test chuyển hợp lệ, và có test xác nhận chuyển không có trong bảng bị từ chối.
- **Property-based** (fast-check) cho bất biến số học: phân bổ Voucher (`0 ≤ d_i ≤ L_i`, `Σ d_i = D`, BR-ORD-02), hoàn tiền lũy kế (`F(q) = N`, BR-RET-07), Số lượng bán được không âm (BR-INV-02).
- **Tiêm lỗi**: DB lỗi giữa tạo Order và Giữ hàng → không commit dở; provider timeout → không gọi lại mù quáng, chờ Đối soát; job chết giữa chừng → chạy lại không tạo tác động trùng.

## Assertion

- Kiểm trạng thái nghiệp vụ cuối cùng (số Order, Tồn kho, Giữ hàng, lượt Voucher, Hoàn tiền), không chỉ status code, URL hoặc toast.
- Kiểm cả **tác động bị cấm**: request bị từ chối thì không có Order, Payment, Giữ hàng, Hàng chờ xuất hay lượt Voucher nào được tạo (BR-ORD-09).
- Expected tính độc lập với code đang test (số viết tay trong test, không gọi lại hàm production).
- Tên test bắt đầu bằng mã luật, ví dụ `it('BR-VCH-10: làm tròn xuống trước khi áp mức giảm tối đa')`, để `grep` từ traceability ra test.
- Không nới assertion hoặc thêm retry để test xanh.

## Môi trường và dữ liệu test

- **Database**: test không bao giờ chạm DB dev. Local dùng database riêng `fashion_store_e2e` trên cùng PostgreSQL native, `prisma migrate reset` rồi `db:seed` trước mỗi lần chạy E2E full-stack. CI dùng service Postgres như hiện tại.
- **Dữ liệu**: seed chỉ chứa danh mục dùng chung (size, màu, Kho, Vai trò hệ thống). Mỗi test tự tạo Người mua, Biến thể, Voucher với mã duy nhất qua API hoặc factory; không test nào dựa vào dữ liệu của test khác; không dùng dữ liệu khách thật.
- **Provider ngoài**: VNPay, MoMo và GHN được thay bằng stub HTTP chạy local, ký và kiểm chữ ký bằng đúng code của Backend với secret test. Stub chủ động gửi được webhook trùng, sai chữ ký, sai số tiền, đến muộn, sai thứ tự. Sandbox thật chỉ dùng cho smoke thủ công trước release; không chạy trong CI, không tiền thật.
- **Thời gian**: Backend đọc giờ qua `Clock` port (ADR 0016 của Backend). Integration và E2E tua thời gian qua port này cho Giữ hàng 15 phút, link thanh toán 10 phút, giỏ vãng lai 30 ngày, hạn Voucher, Giá khuyến mãi, 7 ngày Đổi trả. Không `sleep` theo thời gian thật.
- **Email**: kiểm qua Mailpit (local) hoặc adapter mail giả (CI), không gửi email thật.

## Bản đồ tài liệu

| Cần tìm                                      | Tài liệu                                                                         |
| -------------------------------------------- | -------------------------------------------------------------------------------- |
| FE và BE chịu trách nhiệm gì cho từng luật   | [responsibility-matrix.md](responsibility-matrix.md)                             |
| Hành trình E2E full-stack J0–J9              | [critical-journeys.md](critical-journeys.md)                                     |
| Lịch chạy CI, gate, metric, danh sách N/A    | [quality-gates.md](quality-gates.md)                                             |
| Rubric 15 tiêu chí và prompt audit           | [audit.md](audit.md)                                                             |
| Backend: tầng test, công cụ, traceability    | `be-demo/docs/testing/strategy.md`, `traceability.md`                            |
| CMS: tầng test, công cụ, traceability        | `cms/docs/guides/testing-strategy.md`, `testing-traceability.md`                 |
| Storefront: tầng test, công cụ, traceability | `fe-ecommerce-nike-style/docs/storefront/testing/strategy.md`, `traceability.md` |

## Roadmap

Chưa có ticket; tạo ticket là bước sau khi người dùng yêu cầu.

1. **Backend, theo chuỗi migrate Hexagonal.** Test của mỗi module viết ngay sau khi module đó migrate xong, theo thứ tự task: 43 catalog/category → 44 product, option, pricing → 45 cart → 46 checkout → 47 identity access, internal account → 48 identity auth → 49 finalize. Inventory (41) và voucher (42) đã migrate nên làm trước. `Clock` port đưa vào cùng đợt migrate đầu tiên cần nó. Bật lại ngưỡng coverage 50% ở task 49.
2. **Tính năng chưa build** (task 29 thanh toán online, 32 GHN, 33 Staff xử lý đơn, 34 Đổi trả và Hoàn tiền, 35 email báo đơn, 36 vận hành và báo cáo): spec của task trỏ tới các dòng traceability tương ứng; task chỉ done khi mọi dòng P0 của nó có test PASS.
3. **CMS và Storefront**: không chờ Backend. Bổ sung theo traceability của từng app, ưu tiên P0 (phân quyền, checkout, giỏ).
4. **E2E full-stack**: dựng runner trong repo workspace (Playwright, DB `fashion_store_e2e`, stub provider), chạy J0 và J7 trước; J1–J4 khi Storefront nối giỏ và checkout với API thật; J5, J6, J8, J9 khi tính năng tương ứng merge.
5. **Audit đầu tiên** theo [audit.md](audit.md) sau khi bước 1 xong cho module inventory và voucher, để có điểm gốc.
