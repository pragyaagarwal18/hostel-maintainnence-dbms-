// ============================================================================
// DATABASE SYSTEMS LAB (BCSE302P) - LAB INTERNAL ASSESSMENT 8, 9 & 10
// TOPIC: HOSTEL MAINTENANCE AND COMPLAINT MANAGEMENT SYSTEM
// AUTHORS: PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)
// FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26
// FILE: src/server.js - Express Application Entry Point
// ============================================================================

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const apiRoutes = require('./routes/index');
const Pragya24BCI0280_ErrorHandler = require('./middleware/errorHandler');
const { testDbConnection } = require('./config/db');

const app = express();
const PORT = process.env.PORT || 5000;

// Security & Body Parsing Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve Static Frontend UI
app.use(express.static(path.join(__dirname, '../public')));

// Mount Central API Routes
app.use('/api', apiRoutes);

// Fallback for SPA routing to public/index.html
app.get('*', (req, res, next) => {
  if (req.originalUrl.startsWith('/api')) {
    return next();
  }
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Centralized Error Handling Middleware
app.use(Pragya24BCI0280_ErrorHandler.pragya_notFound);
app.use(Pragya24BCI0280_ErrorHandler.pragya_handleExceptions);

// Server Startup
app.listen(PORT, async () => {
  console.log('======================================================================');
  console.log('   VELLORE INSTITUTE OF TECHNOLOGY - SCOPE');
  console.log('   BCSE302P DATABASE SYSTEMS LAB - ASSESSMENT 8, 9 & 10');
  console.log('   FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26');
  console.log('----------------------------------------------------------------------');
  console.log('   PROJECT: HOSTEL MAINTENANCE & COMPLAINT MANAGEMENT SYSTEM');
  console.log('   AUTHOR 1: PRAGYA AGARWAL (REG NO: 24BCI0280)');
  console.log('   AUTHOR 2: SUHANI SINGH   (REG NO: 24BCI0006)');
  console.log('   TIMESTAMP: ' + new Date().toISOString());
  console.log('======================================================================');
  console.log(`[SERVER ONLINE] Running on: http://localhost:${PORT}`);
  console.log(`[API BASE URL]  http://localhost:${PORT}/api`);
  console.log(`[HEALTH CHECK] http://localhost:${PORT}/api/health`);
  console.log('----------------------------------------------------------------------');

  // Verify Database Connection
  await testDbConnection();
});

module.exports = app;
