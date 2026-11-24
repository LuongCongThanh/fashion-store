# Fashion Store workspace

Repo điều phối cho 3 ứng dụng của Fashion Store. Repo này **không chứa code** của các ứng dụng. Nó chỉ giữ những thứ dùng chung: phiên bản công cụ, cách chạy local, hướng dẫn cho agent, và danh sách skill dùng chung.

| Ứng dụng | Repo | Cổng local |
|---|---|---|
| Backend | [be-demo](https://github.com/LuongCongThanh/be-demo) | 8080 |
| CMS | [fashion-store-cms](https://github.com/LuongCongThanh/fashion-store-cms) | 3001 |
| Storefront | [fe-ecommerce-nike-style](https://github.com/LuongCongThanh/fe-ecommerce-nike-style) | 3000 |

Lý do chọn cách tổ chức này: [ADR 0001](docs/adr/0001-polyrepo-with-coordination-repo.md) và [ADR 0002](docs/adr/0002-automatic-contract-versioning.md).

## Cài đặt lần đầu

Cần có sẵn: [mise](https://mise.jdx.dev/getting-started.html), Docker và PostgreSQL cài trên máy.

```bash
git clone https://github.com/LuongCongThanh/fashion-store.git
cd fashion-store
scripts/bootstrap.sh   # cài công cụ, clone 3 repo, cài dependency, tạo file env
```

### PostgreSQL

Chạy một lần để tạo user và database khớp với `DATABASE_URL` mặc định trong `be-demo/.env`:

```bash
sudo -u postgres createuser --createdb --pwprompt nestjs_demo   # mật khẩu: nestjs_demo
sudo -u postgres createdb --owner nestjs_demo nestjs_demo
```

Sau đó chạy migration của Backend theo README của `be-demo`.

## Hằng ngày

| Việc | Lệnh |
|---|---|
| Chạy tất cả (Redis, Mailpit, 3 app) | `mprocs` |
| Xem trạng thái git cả 3 repo | `mani run status --all` |
| Kéo code mới | `mani run pull --all` |
| Chuyển cả 3 repo về `dev` | `mani run dev --all` |
| Đẩy skill và hướng dẫn chung xuống 3 repo | `scripts/sync.sh` |
| Mở cả 3 repo trong VS Code | `code fashion-store.code-workspace` |

Mailpit (xem email Backend gửi): http://localhost:8025

## Agent

Claude Code, Codex và Copilot đều đọc [AGENTS.md](AGENTS.md). Tên gọi dùng chung nằm trong [GLOSSARY.md](GLOSSARY.md).
