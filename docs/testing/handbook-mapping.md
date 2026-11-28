# Ánh xạ kịch bản handbook

Mỗi kịch bản trong `ecommerce-testing-handbook/08-master-checklist.md` (be-demo `docs/plan/wayfinding/software-architect-ecommerce/`) được xếp vào một trong ba loại:

- **Luật**: khớp một luật của project; kiểm ở các dòng traceability ghi trong cột Ánh xạ (`BR-*`, `T*`, `US-*`, `CMP-*` ở Backend; `CMS-*` ở CMS; `SF-*` ở Storefront).
- **N/A**: không áp dụng cho project, kèm lý do.
- **BA**: rủi ro thật nhưng luật chưa nói tới; cần BA xác nhận trước khi viết test. Danh sách gom ở [cuối file](#khoảng-trống-cần-ba-xác-nhận).

## Tài khoản và phân quyền

| Handbook    | Ánh xạ                                                                                |
| ----------- | ------------------------------------------------------------------------------------- |
| ACCOUNTS-01 | US-501                                                                                |
| ACCOUNTS-02 | US-501                                                                                |
| ACCOUNTS-03 | US-502, SF-AUTH-01                                                                    |
| ACCOUNTS-04 | US-503, SF-AUTH-03                                                                    |
| ACCOUNTS-05 | Quy tắc kiểm soát (Staff bị vô hiệu hoá mất mọi phiên), US-502                        |
| ACCOUNTS-06 | US-502                                                                                |
| ACCOUNTS-07 | **BA**: có đăng nhập Google (US-502, BR-ORD-08) nhưng chưa có luật liên kết Tài khoản |
| ACCOUNTS-08 | **BA**: chưa có luật MFA cho Staff                                                    |
| ACCOUNTS-09 | Ma trận quyền mục 3.2, CMS-PERM-01–04                                                 |
| ACCOUNTS-10 | US-401, US-402, Ownership, SF-ORD-01                                                  |
| ACCOUNTS-11 | **BA**: US-506 không nói rõ có cho đổi email và cách xác thực lại                     |
| ACCOUNTS-12 | SF-AUTH-02, CMS-AUTH-03                                                               |

## Danh mục, Sản phẩm, SKU

| Handbook   | Ánh xạ                                                                               |
| ---------- | ------------------------------------------------------------------------------------ |
| CATALOG-01 | Bổ sung category 2026-11-19 (slug dùng chung vi/en, ổn định)                         |
| CATALOG-02 | Vòng lặp cha con: dòng category ở Backend. **BA**: chưa có giới hạn độ sâu           |
| CATALOG-03 | Bổ sung category 2026-11-19 (ẩn danh mục ẩn cả nhánh)                                |
| CATALOG-04 | **BA**: chưa có luật danh mục chính duy nhất của Sản phẩm                            |
| CATALOG-05 | BR-CAT-03                                                                            |
| CATALOG-06 | BR-CAT-02, BR-CAT-11, CMS-PRD-01                                                     |
| CATALOG-07 | BR-CAT-04, CMS-PRD-03                                                                |
| CATALOG-08 | BR-CAT-05, SF-CAT-04, SF-UI-01                                                       |
| CATALOG-09 | BR-CAT-07                                                                            |
| CATALOG-10 | BR-CAT-09                                                                            |
| CATALOG-11 | SF-CAT-07. Redirect khi đổi slug: N/A, slug không đổi sau khi tạo                    |
| CATALOG-12 | CMS-UI-03. **BA**: Backend chưa có luật chống ghi đè khi hai Admin sửa cùng Sản phẩm |

## Giỏ hàng

| Handbook | Ánh xạ                                                                     |
| -------- | -------------------------------------------------------------------------- |
| CART-01  | BR-ORD-09 (giỏ rỗng không đặt đơn được), SF-UI-01                          |
| CART-02  | BR-CRT-05, SF-CRT-01                                                       |
| CART-03  | BR-CAT-08, SF-CAT-05                                                       |
| CART-04  | BR-CRT-04, SF-CRT-02                                                       |
| CART-05  | **BA**: chưa có luật cho Biến thể trong giỏ khi Sản phẩm chuyển `archived` |
| CART-06  | BR-CRT-03, J4                                                              |
| CART-07  | Ownership giỏ (Backend)                                                    |
| CART-08  | BR-CRT-05 (đồng thời)                                                      |
| CART-09  | SF-CRT-03                                                                  |
| CART-10  | BR-CRT-01, BR-CRT-02, SF-CRT-04                                            |
| CART-11  | SF-CRT-03                                                                  |
| CART-12  | SF-CRT-03                                                                  |

## Giá, thuế, Voucher

| Handbook   | Ánh xạ                                                                            |
| ---------- | --------------------------------------------------------------------------------- |
| PRICING-01 | BR-ORD-07                                                                         |
| PRICING-02 | BR-VCH-10, BR-ORD-02                                                              |
| PRICING-03 | BR-VCH-04                                                                         |
| PRICING-04 | BR-VCH-04 (qua `Clock`)                                                           |
| PRICING-05 | BR-VCH-04, BR-PRC-03 (mốc theo `Clock`), BR-REV-01 (ngày theo giờ Việt Nam)       |
| PRICING-06 | BR-VCH-04, BR-VCH-07 (đồng thời)                                                  |
| PRICING-07 | BR-VCH-07                                                                         |
| PRICING-08 | BR-VCH-01, BR-VCH-02                                                              |
| PRICING-09 | N/A: điều kiện Voucher không có loại trừ SKU hay danh mục (BR-VCH-04)             |
| PRICING-10 | BR-SHP-03                                                                         |
| PRICING-11 | BR-VCH-03, BR-VCH-10                                                              |
| PRICING-12 | BR-RET-07                                                                         |
| PRICING-13 | BR-ORD-02                                                                         |
| Thuế       | N/A: không có luật tính thuế riêng; hoá đơn xuất thủ công (`06-compliance` mục 3) |

## Tồn kho

| Handbook     | Ánh xạ                                                                          |
| ------------ | ------------------------------------------------------------------------------- |
| INVENTORY-01 | BR-INV-02 (đồng thời)                                                           |
| INVENTORY-02 | BR-INV-05, T4                                                                   |
| INVENTORY-03 | BR-INV-07                                                                       |
| INVENTORY-04 | BR-INV-10, BR-SHP-05                                                            |
| INVENTORY-05 | BR-INV-11 (đồng thời)                                                           |
| INVENTORY-06 | BR-INV-04, dòng Rollback                                                        |
| INVENTORY-07 | BR-INV-02                                                                       |
| INVENTORY-08 | BR-INV-09                                                                       |
| INVENTORY-09 | **BA**: luật và kiến trúc chưa mô tả cache Tồn kho; xác nhận có cache hay không |
| INVENTORY-10 | BR-INV-08                                                                       |
| INVENTORY-11 | T4 (job huỷ đơn chạy lại), dòng Outbox                                          |
| INVENTORY-12 | Dòng Rollback (retry P2034 do caller của `TransactionRunner` làm)               |

## Checkout và Đơn hàng

| Handbook    | Ánh xạ                                                              |
| ----------- | ------------------------------------------------------------------- |
| CHECKOUT-01 | BR-ORD-09                                                           |
| CHECKOUT-02 | BR-ORD-04, SF-CHK-01                                                |
| CHECKOUT-03 | BR-ORD-07, BR-SHP-01                                                |
| CHECKOUT-04 | BR-VCH-04, BR-ORD-07                                                |
| CHECKOUT-05 | BR-ORD-07                                                           |
| CHECKOUT-06 | Dòng Idempotency, SF-CHK-03                                         |
| CHECKOUT-07 | Dòng Idempotency                                                    |
| CHECKOUT-08 | Dòng Rollback                                                       |
| CHECKOUT-09 | Dòng Idempotency (thử lại cùng key sau timeout trả đúng đơn đã tạo) |
| CHECKOUT-10 | BR-ORD-02                                                           |
| CHECKOUT-11 | Dòng bảng T1–T14                                                    |
| CHECKOUT-12 | BR-ORD-05, T5, T7, T9, T14                                          |
| CHECKOUT-13 | T2, BR-PAY-06                                                       |
| CHECKOUT-14 | US-401, US-402                                                      |
| CHECKOUT-15 | Dòng Outbox                                                         |

## Thanh toán và Hoàn tiền

| Handbook   | Ánh xạ                                                  |
| ---------- | ------------------------------------------------------- |
| PAYMENT-01 | Dòng Chữ ký                                             |
| PAYMENT-02 | BR-PAY-04. Sai tiền tệ: N/A, chỉ có VND                 |
| PAYMENT-03 | BR-PAY-02                                               |
| PAYMENT-04 | BR-PAY-03                                               |
| PAYMENT-05 | `05-order-lifecycle` mục 4.2                            |
| PAYMENT-06 | Dòng Timeout                                            |
| PAYMENT-07 | Dòng Timeout, BR-PAY-03                                 |
| PAYMENT-08 | `05-order-lifecycle` mục 4.1, BR-PAY-05                 |
| PAYMENT-09 | BR-PAY-04 (thông báo failed/pending không xác nhận đơn) |
| PAYMENT-10 | BR-RET-07, BR-REF-05                                    |
| PAYMENT-11 | BR-REF-06                                               |
| PAYMENT-12 | BR-REF-06                                               |
| PAYMENT-13 | BR-PAY-02 (job Đối soát)                                |
| PAYMENT-14 | Dòng Chữ ký (log không chứa secret, dữ liệu thẻ)        |

## Vận chuyển

| Handbook    | Ánh xạ                                                                                |
| ----------- | ------------------------------------------------------------------------------------- |
| SHIPPING-01 | **BA**: chưa có luật khi GHN không phục vụ địa chỉ (chỉ có ánh xạ phường/xã, US-1004) |
| SHIPPING-02 | BR-SHP-01, BR-CAT-06                                                                  |
| SHIPPING-03 | BR-ORD-07 (Tính thử có hạn, gồm phí ship)                                             |
| SHIPPING-04 | BR-SHP-02                                                                             |
| SHIPPING-05 | BR-SHP-05                                                                             |
| SHIPPING-06 | BR-SHP-06. **BA**: cách xác thực nguồn webhook GHN chưa có trong luật                 |
| SHIPPING-07 | `05-order-lifecycle` mục 4.2                                                          |
| SHIPPING-08 | T12, BR-INV-08                                                                        |
| SHIPPING-09 | BR-SHP-07. Đối chiếu tiền COD với GHN: N/A, ngoài MVP (BR-REF-04)                     |
| SHIPPING-10 | `05-order-lifecycle` mục 4.5, BR-SHP-08                                               |
| SHIPPING-11 | BR-SHP-05 (bàn giao lại dùng lại Vận đơn)                                             |
| SHIPPING-12 | **BA**: chưa có luật đối chiếu Cước vận chuyển thực tế với phí đã báo                 |

## Đổi trả

| Handbook   | Ánh xạ                                                                        |
| ---------- | ----------------------------------------------------------------------------- |
| RETURNS-01 | BR-RET-01                                                                     |
| RETURNS-02 | BR-RET-08                                                                     |
| RETURNS-03 | BR-RET-07, BR-RET-08                                                          |
| RETURNS-04 | BR-RET-02, BR-RET-03                                                          |
| RETURNS-05 | BR-RET-08 (đồng thời, mốc `k` lũy kế)                                         |
| RETURNS-06 | BR-RET-07                                                                     |
| RETURNS-07 | BR-INV-08, BR-RET-08                                                          |
| RETURNS-08 | Ma trận quyền mục 3.2                                                         |
| RETURNS-09 | Quy tắc kiểm soát (lịch sử thao tác back-office)                              |
| RETURNS-10 | BR-REF-03 (Staff hoàn thủ công, không gọi Cổng), `05-order-lifecycle` mục 4.4 |
| RETURNS-11 | `05-order-lifecycle` mục 4.4                                                  |

## CMS và back-office

| Handbook | Ánh xạ                                                   |
| -------- | -------------------------------------------------------- |
| CMS-01   | CMS-PERM-01, CMS-PERM-02                                 |
| CMS-02   | CMS-PERM-05                                              |
| CMS-03   | N/A: không có user story cho bulk action                 |
| CMS-04   | N/A: không có user story cho import CSV                  |
| CMS-05   | `06-compliance` mục 3 (xuất đơn đã thu tiền), CMS-CUS-01 |
| CMS-06   | BR-CAT-07, CMS-PRD-02                                    |
| CMS-07   | CMS-UI-03                                                |
| CMS-08   | Quy tắc kiểm soát, CMP-07, CMS-AUD-01                    |
| CMS-09   | CMS-UI-02                                                |
| CMS-10   | CMS-ORD-02                                               |
| CMS-11   | **BA**: chưa có luật loại và kích thước file ảnh tải lên |
| CMS-12   | CMS-AUTH-02                                              |

## Tìm kiếm, review, thông báo

| Handbook  | Ánh xạ                                                               |
| --------- | -------------------------------------------------------------------- |
| SEARCH-01 | BR-CAT-13                                                            |
| SEARCH-02 | BR-CAT-14, BR-CAT-15, SF-CAT-02                                      |
| SEARCH-03 | BR-CAT-12, SF-CAT-02. **BA**: chưa có luật thứ tự phụ khi bằng nhau  |
| SEARCH-04 | BR-CAT-14/15 (phân trang không trùng), SF-CAT-02                     |
| SEARCH-05 | N/A: không có search index riêng, tìm trực tiếp trên tên (BR-CAT-13) |
| SEARCH-06 | N/A: không có review trong MVP                                       |
| SEARCH-07 | N/A: không có review trong MVP                                       |
| SEARCH-08 | SF bảo mật (không render HTML thô từ Backend)                        |
| SEARCH-09 | BR-NTF-01                                                            |
| SEARCH-10 | BR-NTF-01, dòng Outbox                                               |
| SEARCH-11 | CMP-03. Gửi email marketing: N/A, MVP chưa gửi                       |
| SEARCH-12 | BR-NTF-02                                                            |
| SEARCH-13 | BR-NTF-01, CMP-07                                                    |

## Khoảng trống cần BA xác nhận

ACCOUNTS-07 (liên kết Google), ACCOUNTS-08 (MFA Staff), ACCOUNTS-11 (đổi email), CATALOG-02 (độ sâu danh mục), CATALOG-04 (danh mục chính), CATALOG-12 (Admin sửa cùng lúc), CART-05 (Biến thể `archived` trong giỏ), INVENTORY-09 (cache Tồn kho), SHIPPING-01 (địa chỉ GHN không phục vụ), SHIPPING-06 (xác thực webhook GHN), SHIPPING-12 (đối chiếu cước), CMS-11 (file tải lên), SEARCH-03 (thứ tự phụ khi sắp xếp).

Khi BA bổ sung luật: thêm vào `be-demo/docs/business/`, thêm dòng traceability, rồi đổi ô tương ứng ở đây thành mã luật.
