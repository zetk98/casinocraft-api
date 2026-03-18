# 🚀 Deploy API Server - Hướng Dẫn Chi Tiết

## BẮC 1: Chuẩn bị GitHub Repository

### Option A: Dùng GitHub Desktop (Dễ nhất)

```
1. Mở GitHub Desktop
2. Click "+" → "New repository"
3. Điền thông tin:
   - Repository name: casinocraft-api
   - Description: CasinoCraft API Server for launcher
   - Public/Private: Public (hoặc Private cũng được)
4. ❌ Bỏ chọn "Add a README file"
5. ❌ Bỏ chọn "Add .gitignore"
6. Click "Create repository"
7. Copy repository URL (https://github.com/USERNAME/casinocraft-api.git)
```

### Option B: Dùng GitHub Website

```
1. Vào: https://github.com/new
2. Điền thông tin như trên
3. Click "Create repository"
```

---

## BƯỚC 2: Push Code Lên GitHub

### Cách 1: Chạy Script Tự Động (Khuyên dùng)

```bash
cd D:/casino-api-server
deploy-to-github.bat
```

Script sẽ tự động:
- ✅ Initialize git nếu chưa có
- ✅ Add tất cả files
- ✅ Commit changes
- ✅ Push lên GitHub

### Cách 2: Manual (Nếu script lỗi)

```bash
cd D:/casino-api-server

# Initialize git
git init

# Add files
git add .

# Commit
git commit -m "Initial commit - CasinoCraft API Server"

# Add remote (thay USERNAME bằng username GitHub của bạn)
git remote add origin https://github.com/YOUR_USERNAME/casinocraft-api.git

# Push
git push -u origin main
```

---

## BƯỚC 3: Deploy Lên Railway

### 3.1 Tài Railway CLI (Optional)

```bash
npm install -g @railway/cli
```

### 3.2 Deploy qua Website

```
1. Vào: https://railway.app/
2. Đăng ký bằng GitHub
   - Click "Continue with GitHub"
   - Authorize Railway

3. Sau khi login:
   - Click "New Project"
   - Chọn "Deploy from GitHub repo"

4. Chọn repository: casinocraft-api

5. Railway sẽ tự động:
   - Detect Node.js app
   - Install dependencies
   - Start server
   - Generate URL: https://casinocraft-api.up.railway.app

6. Click nút "Visit" để test API
```

---

## BƯỚC 4: Test API

### Test Health Endpoint

```
Trình duyệt: https://casinocraft-api.up.railway.app/api/health
```

Expected result:
```json
{
  "status": "ok",
  "server": "CasinoCraft API Server",
  "version": "1.0.0",
  "timestamp": "2025-03-18T..."
}
```

### Test Mods Endpoint

```
https://casinocraft-api.up.railway.app/api/mods/required
```

---

## BƯỚC 5: Upload Mods (Nếu Railway host files)

### Cách 1: Add mods vào git repository

```bash
cd D:/casino-api-server

# Copy mods from pokermc build
copy ..\pokermc\build\libs\*.jar mods\

# Add to git
git add mods/
git commit -m "Add mods files"
git push
```

### Cách 2: Upload trực tiếp lên Railway

1. Trong Railway dashboard → Project → casinocraft-api
2. Tab "Services"
3. Tìm deployment service → "Upload"
4. Upload `casinocraft-1.0.1.jar`
5. URL sẽ là: `https://casinocraft-api.up.railway.app/mods/casinocraft-1.0.1.jar`

---

## BƯỚC 6: Cập Nhật Launcher Config

```json
// D:/CasinoLauncher/config/launcher-config.json
{
  "api": {
    "baseUrl": "https://casinocraft-api.up.railway.app"
  }
}
```

---

## BƯỚC 7: Test Launcher

```bash
cd D:/CasinoLauncher
run.bat
```

Launcher sẽ:
1. Connect đến Railway API
2. Fetch mods list
3. Download mods (nếu có)
4. Install vào `.minecraft/mods/`

---

## 🔧 Troubleshooting

### Lỗi: "Remote origin already exists"

```bash
# Remove existing remote
git remote remove origin

# Add again
git remote add origin https://github.com/USERNAME/casinocraft-api.git
```

### Lỗi: "failed to push"

**Nguyên nhân:** Authentication failed

**Giải pháp:**
1. Tạo Personal Access Token:
   - GitHub → Settings → Developer settings → Personal access tokens
   - Generate new token (classic)
   - Scopes: repo (full control)

2. Push lại:
   ```bash
   git push
   # Khi được hỏi password, paste token vào
   ```

### Lỗi: Railway build failed

**Nguyên nhân:** Dependencies hoặc config error

**Giải pháp:**
1. Check Railway logs: Railway dashboard → project → "Deployments"
2. Xem log để biết lỗi gì
3. Fix và push lại

---

## ✅ Check-list

Trước khi test launcher:

- [ ] GitHub repository đã tạo
- [ ] Code đã push lên GitHub
- [ ] Railway project đã tạo
- [ ] Railway URL hoạt động (test `/api/health`)
- [ ] Mods đã upload hoặc có sẵn
- [ ] Launcher config đã update với Railway URL

---

*Good luck! Hỏi tôi nếu gặp lỗi ở bước nào.*
