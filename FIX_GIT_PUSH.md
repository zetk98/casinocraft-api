# 🔧 Fix Lỗi CMD Tắt Ngay - Git Push

## 🐛 Vấn đề
```
Chạy deploy-to-github.bat
→ CMD mở ra và tắt ngay lập tức
→ Code không lên được GitHub
```

## ✅ Giải pháp (Bước-từng)

### Bước 1: KIỂM TRA INSTALLATION

Chạy script check:
```bash
cd D:/casino-api-server
check-setup.bat
```

**Nếu thấy "FAIL Git NOT FOUND":**
1. Tải Git: https://git-scm.com/download/win
2. Cài đặt (không cần restart CMD)
3. Chạy lại check-setup.bat

---

### Bước 2: SETUP GIT CHỈ CÓ PUSH

```bash
cd D:/casino-api-server
setup-git-only.bat
```

Script này sẽ:
- ✅ Initialize git
- ✅ Add files
- ✅ Create commit
- ✅ Hỏi nhập GitHub URL
- ✅ Add remote origin

**Output khi thành công:**
```
[SUCCESS] Git repository da duoc setup!
Next step: Add GitHub remote and push

Nhap GitHub URL: https://github.com/USERNAME/casinocraft-api.git
```

---

### Bước 3: PUSH LÊN GITHUB

Cách 1: Dùng script tự động (SAU KHI setup-git-only.bat hoàn thành)

```bash
cd D:/casino-api-server
deploy-to-github-fixed.bat
```

Cách 2: Manual (nếu script vẫn lỗi)

```bash
cd D:/casino-api-server

# Check git status
git status

# Push
git push -u origin main
```

---

## 📝 Cách xác nhận SUCCESS

**Check trên GitHub:**
```
1. Vào: https://github.com/YOUR_USERNAME/casinocraft-api
2. Xem có các file:
   - server.js
   - package.json
   - mods.json
   - config.json
   - etc.
```

---

## 🐛 Nếu vẫn Lỗi

### Lỗi: "fatal: repository does not exist"

**Nguyên nhân:** Repository chưa được tạo trên GitHub

**Giải pháp:**
```
1. Vào: https://github.com/new
2. Tạo repository: casinocraft-api
3. Copy URL
4. Chạy lại script
```

### Lỗi: "Authentication failed"

**Nguyên nhân:** Sai password hoặc chưa có SSH key

**Giải pháp:**

**Option A: Dùng Personal Access Token**
```
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scopes: repo (full control)
4. Khi push:
   - Username: GitHub username
   - Password: Paste token (NOT GitHub password)
```

**Option B: Dùng GitHub Desktop**
```
1. GitHub Desktop → "+" → Clone repository
2. Point to D:/casino-api-server
3. Desktop sẽ handle authentication
```

---

## 🎯 Quick Test (Kiểm tra Git hoạt động)

```bash
# Test git command
git --version

# Test git status
cd D:/casino-api-server
git status
```

Nếu output hiển thị normally → Git hoạt động tốt.

---

*Thử chạy và báo lại lỗi cụ thể nếu có!*
