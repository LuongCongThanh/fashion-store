# Audit chất lượng test

Audit đánh giá bộ test có bắt được lỗi thật không, không dựa vào số test, coverage hay CI xanh. Chạy audit đầu tiên khi test của inventory và voucher đã xong (xem [Roadmap](README.md#roadmap)), sau đó trước mỗi lần release lên `main`. Báo cáo lưu trong repo workspace `docs/testing/audits/<YYYY-MM-DD>.md`; giữ báo cáo cũ, không sửa số liệu lịch sử.

## Rubric 15 tiêu chí

| #   | Tiêu chí             | Trọng số | Câu hỏi chính                                                                        |
| --- | -------------------- | -------: | ------------------------------------------------------------------------------------ |
| 1   | Requirement coverage |       10 | Mỗi luật `BR-*` đã build có test trong traceability?                                 |
| 2   | Risk coverage        |       10 | Mọi luật P0 có test ở đúng tầng đã chọn?                                             |
| 3   | Fault detection      |       12 | Mutation score; cố tình đưa lỗi vào thì test có fail?                                |
| 4   | Assertion quality    |       10 | Kiểm trạng thái nghiệp vụ và tác động bị cấm, không chỉ `toBeDefined`?               |
| 5   | Test design          |        8 | Có biên, bảng quyết định, chuyển trạng thái, property-based khi phù hợp?             |
| 6   | Architecture         |        6 | Tầng thấp nhất còn hiệu quả; không lặp mọi thứ ở mọi tầng?                           |
| 7   | Code coverage        |        4 | Vượt sàn 50%; vùng chưa phủ có phải vùng rủi ro?                                     |
| 8   | Integration fidelity |        8 | Postgres thật; không mock Persistence Port trong integration; stub provider ký thật? |
| 9   | Reliability          |        7 | Độc lập, chạy song song được, không `sleep`, thời gian qua `Clock`?                  |
| 10  | Maintainability      |        5 | Tên theo mã luật, Given–When–Then, không phụ thuộc chi tiết implementation?          |
| 11  | Efficiency           |        5 | Không trùng vô ích; thời gian CI trong ngân sách?                                    |
| 12  | Non-functional       |        5 | Auth, injection, rate limit, idempotency, accessibility checkout?                    |
| 13  | Test data            |        3 | Seed tái tạo được, dữ liệu riêng mỗi test, không dữ liệu thật?                       |
| 14  | CI/CD gates          |        4 | Gate trong [quality-gates.md](quality-gates.md) chạy tự động, không bị bỏ qua?       |
| 15  | Production feedback  |        3 | Lỗi lọt có regression test? (N/A cho tới khi có production)                          |

**Chấm điểm**: mỗi tiêu chí 0–5 theo bằng chứng (0 chưa có, 1 tự phát, 2 cơ bản, 3 có quy ước, 4 có đo lường, 5 tối ưu). Điểm = 100 × Σ(trọng số × điểm/5) / Σ(trọng số áp dụng). N/A cần lý do và được loại khỏi mẫu số. Thiếu bằng chứng ghi **Not assessed**, không coi là N/A, và báo điểm là tạm tính. Tham khảo: ≥ 90 rất tốt, ≥ 80 tốt, ≥ 70 khá, < 60 cần cải thiện. Điểm không thay [gate](quality-gates.md#gate-không-bù-được-bằng-điểm).

## Quy trình

1. Đọc luật (`be-demo/docs/business/`), traceability của ba app, kiến trúc và ADR liên quan.
2. Lập inventory test theo app, module, tầng.
3. Đối chiếu traceability: luật nào thiếu test, test nào không trỏ tới luật.
4. Đọc assertion, mock, dữ liệu; tìm test yếu, trùng, sai tầng, phụ thuộc implementation.
5. Chạy test trong môi trường cô lập; ghi đúng lệnh và kết quả.
6. Lấy coverage và mutation nếu có.
7. Chấm 15 tiêu chí, xét gate riêng.
8. Liệt kê phát hiện P0–P3 và đề xuất thêm, sửa, gộp, thay hoặc xoá test kèm lý do.

## Prompt cho agent

```text
Đóng vai kiến trúc sư chất lượng phần mềm cho một hệ thống thương mại điện tử gồm Backend
(NestJS, Prisma, PostgreSQL), CMS (Vue) và Storefront (Next.js).
Đọc trước: docs/testing/ của repo workspace; be-demo/docs/business/ (luật BR-*, vòng đời
đơn T1–T14, ma trận quyền); docs testing của từng app (strategy và traceability).
Nhiệm vụ: audit toàn bộ bộ test theo docs/testing/audit.md.
- Lập ma trận luật → kịch bản → test, đánh dấu thiếu, yếu, trùng, lỗi thời, dễ vỡ.
- Kiểm bất biến tiền, Tồn kho, phân quyền và chuyển trạng thái.
- Đánh giá assertion, mock (không mock thứ đang test, không mock Persistence Port trong
  integration), tầng test và độ ổn định.
- Chỉ chạy test trong môi trường cô lập: DB fashion_store_e2e hoặc CI, stub provider.
  Không dùng thanh toán thật, không dùng dữ liệu khách thật, không chạm DB dev.
- Ghi đúng lệnh đã chạy và kết quả; không bịa số liệu; không báo PASS cho test chưa chạy.
- Thiếu bằng chứng ghi Not assessed; N/A phải có lý do.
- Chấm 15 tiêu chí và báo gate riêng; điểm cao không che gate fail.
- Không sửa code hay test trong lúc audit. Không đề xuất thêm test chỉ để tăng coverage;
  không đề xuất xoá test khi chưa xét rủi ro nó bảo vệ.
Kết quả: báo cáo Markdown gồm tóm tắt, kiến trúc test hiện tại, inventory, phân tích
requirement và risk coverage, kịch bản thiếu, assertion yếu, mock, trùng lặp, độ ổn định,
coverage và mutation, đánh giá Backend / CMS / Storefront, CI, điểm, gate, phát hiện P0–P3,
đề xuất, roadmap, rủi ro còn lại và giới hạn của audit; mỗi phát hiện kèm đường dẫn file.
```

## Sau audit

Muốn sửa theo audit thì tách thành ticket trong repo của từng app. Với mỗi lỗi tìm được: viết regression test fail trước, sửa, rồi chạy lại bộ test liên quan. Không nới assertion hoặc bỏ qua test fail để xanh.
