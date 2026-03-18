/**
 * CasinoCraft API Server
 * Serves mod list, news, and file downloads for CasinoLauncher
 */

const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');

// Load config
const config = require('./config.json');

const app = express();
// Railway requires PORT from environment variable
const PORT = process.env.PORT || config.port || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files for mod downloads
app.use('/mods', express.static(path.join(__dirname, 'mods')));

// File upload configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const modsDir = path.join(__dirname, 'mods');
    if (!fs.existsSync(modsDir)) {
      fs.mkdirSync(modsDir, { recursive: true });
    }
    cb(null, modsDir);
  },
  filename: (req, file, cb) => {
    // Keep original filename
    cb(null, file.originalname);
  }
});

const upload = multer({ storage: storage });

// ============================================
// API ENDPOINTS
// ============================================

/**
 * GET /api/health
 * Health check endpoint
 */
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    server: 'CasinoCraft API Server',
    version: require('./package.json').version,
    timestamp: new Date().toISOString()
  });
});

/**
 * GET /api/mods/required
 * Get list of required mods
 */
app.get('/api/mods/required', (req, res) => {
  try {
    const modsData = loadModsData();
    res.json({
      success: true,
      data: modsData
    });
  } catch (error) {
    console.error('Error loading mods:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * GET /api/news
 * Get news and announcements
 */
app.get('/api/news', (req, res) => {
  try {
    const newsData = loadNewsData();
    res.json({
      success: true,
      data: newsData
    });
  } catch (error) {
    console.error('Error loading news:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * GET /api/launcher/update
 * Check for launcher updates
 */
app.get('/api/launcher/update', (req, res) => {
  const launcherVersion = req.query.version || '1.0.0';

  res.json({
    success: true,
    data: {
      latestVersion: config.launcherVersion || '1.0.0',
      downloadUrl: config.launcherDownloadUrl || '',
      changelog: config.launcherChangelog || 'Initial release'
    }
  });
});

/**
 * GET /api/mods/:modId/download
 * Get download URL for a specific mod
 */
app.get('/api/mods/:modId/download', (req, res) => {
  try {
    const modId = req.params.modId;
    const modsData = loadModsData();

    // Find the mod
    const allMods = [
      ...modsData.requiredMods,
      ...modsData.optionalMods
    ];

    const mod = allMods.find(m => m.id === modId);

    if (!mod) {
      return res.status(404).json({
        success: false,
        error: 'Mod not found'
      });
    }

    // Check if file exists
    const modPath = path.join(__dirname, 'mods', path.basename(mod.url));

    if (!fs.existsSync(modPath)) {
      return res.status(404).json({
        success: false,
        error: 'Mod file not found on server'
      });
    }

    // Return download URL and file info
    res.json({
      success: true,
      data: {
        downloadUrl: `${config.baseUrl}/mods/${path.basename(mod.url)}`,
        filename: path.basename(mod.url),
        size: fs.statSync(modPath).size,
        sha256: mod.sha256
      }
    });

  } catch (error) {
    console.error('Error getting mod download:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * POST /api/admin/upload
 * Upload a new mod file (admin endpoint)
 */
app.post('/api/admin/upload', upload.single('mod'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No file uploaded'
      });
    }

    // Calculate SHA256
    const fileBuffer = fs.readFileSync(req.file.path);
    const sha256 = crypto.createHash('sha256').update(fileBuffer).digest('hex');

    // Get file info from request body
    const modInfo = JSON.parse(req.body.info || '{}');

    // Add file info
    const uploadedMod = {
      filename: req.file.filename,
      originalName: req.file.originalname,
      size: req.file.size,
      sha256: sha256,
      mimetype: req.file.mimetype,
      uploadDate: new Date().toISOString(),
      ...modInfo
    };

    // Save to mods.json if requested
    if (req.body.addToModsList === 'true') {
      addToModsList(uploadedMod);
    }

    res.json({
      success: true,
      data: {
        message: 'File uploaded successfully',
        file: uploadedMod,
        downloadUrl: `${config.baseUrl}/mods/${req.file.filename}`
      }
    });

  } catch (error) {
    console.error('Error uploading file:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * GET /api/mods
 * Get all mods (admin endpoint)
 */
app.get('/api/mods', (req, res) => {
  try {
    const modsData = loadModsData();

    // List all files in mods directory
    const modsDir = path.join(__dirname, 'mods');
    const files = [];

    if (fs.existsSync(modsDir)) {
      const fileNames = fs.readdirSync(modsDir);

      for (const fileName of fileNames) {
        if (fileName.endsWith('.jar')) {
          const filePath = path.join(modsDir, fileName);
          const stats = fs.statSync(filePath);

          files.push({
            filename: fileName,
            size: stats.size,
            uploadDate: stats.mtime.toISOString(),
            downloadUrl: `${config.baseUrl}/mods/${fileName}`
          });
        }
      }
    }

    res.json({
      success: true,
      data: {
        mods: modsData,
        files: files
      }
    });

  } catch (error) {
    console.error('Error listing mods:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// ============================================
// DATA LOADING FUNCTIONS
// ============================================

function loadModsData() {
  const modsJsonPath = path.join(__dirname, 'mods.json');

  if (!fs.existsSync(modsJsonPath)) {
    // Return default data if mods.json doesn't exist
    return {
      serverVersion: "1.0.0",
      minecraftVersion: "1.21.1",
      loader: "fabric",
      loaderVersion: "0.15.11",
      requiredMods: [
        {
          id: "casinocraft",
          name: "CasinoCraft",
          version: "1.0.1",
          url: `${config.baseUrl}/mods/casinocraft-1.0.1.jar`,
          sha256: "abc123def456",
          size: 3500000,
          changelog: "• Fixed dice roll timing\n• Added history colors\n• Improved last player kick logic",
          required: true,
          filename: "casinocraft-1.0.1.jar"
        }
      ],
      optionalMods: [
        {
          id: "sodium",
          name: "Sodium",
          version: "0.5.0",
          url: `${config.baseUrl}/mods/sodium-0.5.0.jar`,
          sha256: "def456ghi789",
          size: 800000,
          changelog: "Performance improvements",
          required: false,
          filename: "sodium-0.5.0.jar"
        }
      ]
    };
  }

  const content = fs.readFileSync(modsJsonPath, 'utf8');
  return JSON.parse(content);
}

function loadNewsData() {
  const newsJsonPath = path.join(__dirname, 'news.json');

  if (!fs.existsSync(newsJsonPath)) {
    // Return default news
    return {
      news: [
        {
          id: "1",
          title: "Chào mừng đến CasinoCraft!",
          date: new Date().toISOString().split('T')[0],
          content: "Tải launcher để nhận cập nhật tự động mods!",
          important: true
        },
        {
          id: "2",
          title: "Update 1.0.1 Released",
          date: "2025-03-18",
          content: "Fixed dice roll timing, added history colors, improved last player kick logic",
          important: false
        }
      ]
    };
  }

  const content = fs.readFileSync(newsJsonPath, 'utf8');
  return JSON.parse(content);
}

function addToModsList(modInfo) {
  // Add mod to mods.json
  const modsJsonPath = path.join(__dirname, 'mods.json');
  let modsData = { requiredMods: [], optionalMods: [] };

  if (fs.existsSync(modsJsonPath)) {
    modsData = JSON.parse(fs.readFileSync(modsJsonPath, 'utf8'));
  }

  const newMod = {
    id: modInfo.id || modInfo.filename?.replace('.jar', ''),
    name: modInfo.name || modInfo.id,
    version: modInfo.version || '1.0.0',
    url: `${config.baseUrl}/mods/${modInfo.filename}`,
    sha256: modInfo.sha256,
    size: modInfo.size,
    changelog: modInfo.changelog || '',
    required: modInfo.required !== false,
    filename: modInfo.filename
  };

  if (newMod.required !== false) {
    // Check if mod already exists
    const existingIndex = modsData.requiredMods.findIndex(m => m.id === newMod.id);
    if (existingIndex >= 0) {
      modsData.requiredMods[existingIndex] = newMod;
    } else {
      modsData.requiredMods.push(newMod);
    }
  } else {
    modsData.optionalMods.push(newMod);
  }

  fs.writeFileSync(modsJsonPath, JSON.stringify(modsData, null, 2));
}

// ============================================
// ERROR HANDLING
// ============================================

app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found'
  });
});

app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    error: err.message
  });
});

// ============================================
// START SERVER
// ============================================

app.listen(PORT, () => {
  console.log('╔══════════════════════════════════════════════╗');
  console.log('║   CasinoCraft API Server                    ║');
  console.log('╚══════════════════════════════════════════════╝');
  console.log('');
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 API URL: http://localhost:${PORT}`);
  console.log('');
  console.log('📌 Endpoints:');
  console.log('   GET  /api/health');
  console.log('   GET  /api/mods/required');
  console.log('   GET  /api/news');
  console.log('   GET  /api/launcher/update');
  console.log('   GET  /api/mods/:modId/download');
  console.log('   POST /api/admin/upload');
  console.log('   GET  /api/mods');
  console.log('');
  console.log('📦 Mods directory: ' + path.join(__dirname, 'mods'));
  console.log('📄 Config file: config.json');
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('─────────────────────────────────────────────');
});

module.exports = app;
