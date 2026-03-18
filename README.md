# CasinoCraft API Server

API server cho CasinoLauncher - cung cấp danh sách mods, news và file downloads.

## 🚀 Quick Start

### Cách 1: Dùng batch file (Windows)

```
Double-click vào start.bat
```

### Cách 2: Manual

```bash
# 1. Cài dependencies
npm install

# 2. Start server
node server.js

# Hoặc với dev mode (auto-restart)
npm run dev
```

Server sẽ chạy tại: **http://localhost:3000**

---

## 📋 API Endpoints

### GET /api/health
Health check

**Response:**
```json
{
  "status": "ok",
  "server": "CasinoCraft API Server",
  "version": "1.0.0",
  "timestamp": "2025-03-18T10:30:00.000Z"
}
```

### GET /api/mods/required
Lấy danh sách mods cần thiết

**Response:**
```json
{
  "success": true,
  "data": {
    "serverVersion": "1.0.0",
    "minecraftVersion": "1.21.1",
    "loader": "fabric",
    "requiredMods": [
      {
        "id": "casinocraft",
        "name": "CasinoCraft",
        "version": "1.0.1",
        "url": "http://localhost:3000/mods/casinocraft-1.0.1.jar",
        "sha256": "abc123...",
        "size": 3500000,
        "changelog": "• Fix bug A\n• Add feature B",
        "required": true
      }
    ],
    "optionalMods": [...]
  }
}
```

### GET /api/news
Lấy danh sách tin tức

**Response:**
```json
{
  "success": true,
  "data": {
    "news": [
      {
        "id": "1",
        "title": "Update 1.0.1 Released",
        "date": "2025-03-18",
        "content": "New features and bug fixes"
      }
    ]
  }
}
```

### GET /api/launcher/update
Kiểm tra launcher update

**Query params:** `?version=1.0.0`

**Response:**
```json
{
  "success": true,
  "data": {
    "latestVersion": "1.0.0",
    "downloadUrl": "http://localhost:3000/launcher/CasinoLauncher.exe",
    "changelog": "Initial release"
  }
}
```

### GET /api/mods/:modId/download
Lấy thông tin download mod

**Response:**
```json
{
  "success": true,
  "data": {
    "downloadUrl": "http://localhost:3000/mods/casinocraft-1.0.1.jar",
    "filename": "casinocraft-1.0.1.jar",
    "size": 3500000,
    "sha256": "abc123..."
  }
}
```

### POST /api/admin/upload
Upload mod file (admin endpoint)

**Form data:**
- `mod`: JAR file
- `info`: JSON string with mod info
- `addToModsList`: "true" to add to mods.json

### GET /api/mods
Liệt kê tất cả mods và files (admin)

---

## 📁 Cấu trúc

```
casino-api-server/
├── server.js              ← Main server file
├── package.json           ← Node.js dependencies
├── config.json            ← Server configuration
├── mods.json              ← Mods data
├── news.json              ← News data
├── mods/                  ← Mod JAR files directory
│   ├── casinocraft-1.0.1.jar
│   └── sodium-0.5.0.jar
├── start.bat              ← Start server (Windows)
├── update-mods.bat        ← Copy mods from pokermc build
└── README.md              ← File này
```

---

## 🔄 Workflow

### 1. Development (Local)

```bash
# Terminal 1: Start API server
cd casino-api-server
start.bat

# Terminal 2: Test launcher
cd CasinoLauncher
run.bat
```

### 2. Cập nhật mods sau khi build pokermc

```bash
# 1. Build pokermc
cd ../pokermc
./gradlew build

# 2. Copy JAR to API server
cd ../casino-api-server
update-mods.bat

# 3. Launcher sẽ tự động download version mới
```

### 3. Deploy lên server thật

#### Option A: VPS/Cloud Server
```bash
# 1. Upload files to server
scp -r casino-api-server/* user@server:/var/www/casino-api/

# 2. SSH into server
ssh user@server

# 3. Install dependencies
cd /var/www/casino-api
npm install

# 4. Start server (with PM2 for production)
pm2 start server.js --name casino-api

# Or with systemd (Linux)
# Create service file in /etc/systemd/system/
```

#### Option B: Cloud Platform
- **Heroku:** `git push heroku main`
- **Railway:** Connect GitHub repo
- **Render:** Connect GitHub repo
- **Vercel:** Connect GitHub repo

---

## 🔧 Cấu hình

### Thay đổi port
Edit `config.json`:
```json
{
  "port": 8080
}
```

### Thay đổi baseUrl (cho deployment)
Edit `config.json`:
```json
{
  "baseUrl": "https://api.casinocraft.com"
}
```

### Enable CORS cho production
Trong `server.js`, change:
```javascript
app.use(cors({
  origin: ['https://your-domain.com'],
  credentials: true
}));
```

---

## 🛡️ Security (Production)

### Enable API Key
```javascript
const apiKey = process.env.API_KEY;

app.use((req, res, next) => {
  const key = req.headers['x-api-key'];
  if (key !== apiKey) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
});
```

### Rate Limiting
```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

---

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:3000/api/health
```

### Log Files
```bash
# Save logs to file
node server.js > logs/server.log 2>&1
```

---

## 🔗 Integration với Pokermc Project

### Tự động update mods khi build

1. **Build pokermc:**
   ```bash
   cd ../pokermc
   ./gradlew build
   ```

2. **Copy JARs:**
   ```bash
   cd ../casino-api-server
   update-mods.bat
   ```

3. **Launcher sẽ tự động:**
   - Check API
   - Phát hiện version mới
   - Download tự động
   - Install vào `.minecraft/mods/`

---

## 📝 Development Tips

### Test API endpoints
```bash
# Health check
curl http://localhost:3000/api/health

# Get mods
curl http://localhost:3000/api/mods/required

# Get news
curl http://localhost:3000/api/news
```

### Auto-restart on file changes
```bash
npm install -g nodemon
nodemon server.js
```

### Debug mode
```bash
DEBUG=* node server.js
```

---

## 🚀 Deployment Checklist

- [ ] Update `config.json` baseUrl
- [ ] Set environment variables (API key, etc.)
- [ ] Enable HTTPS (nginx, Let's Encrypt)
- [ ] Set up process manager (PM2, systemd)
- [ ] Configure firewall rules
- [ ] Set up monitoring/logging
- [ ] Test from launcher

---

*Last updated: 2025-03-18*
# Trigger Railway redeploy
