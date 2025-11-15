const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');
const PITCHES_FILE = path.join(DATA_DIR, 'pitches.json');
const BOOKINGS_FILE = path.join(DATA_DIR, 'bookings.json');

function ensureFileExists(filePath, fallbackContent) {
  if (!fs.existsSync(filePath)) {
    fs.mkdirSync(path.dirname(filePath), { recursive: true });
    fs.writeFileSync(filePath, JSON.stringify(fallbackContent, null, 2));
  }
}

function readJson(filePath, fallback) {
  ensureFileExists(filePath, fallback);
  const raw = fs.readFileSync(filePath, 'utf8');
  try {
    return JSON.parse(raw);
  } catch (error) {
    console.error(`Failed to parse ${filePath}.`, error);
    return fallback;
  }
}

function writeJson(filePath, data) {
  ensureFileExists(filePath, data);
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
}

function loadPitches() {
  return readJson(PITCHES_FILE, []);
}

function savePitches(pitches) {
  writeJson(PITCHES_FILE, pitches);
}

function loadBookings() {
  return readJson(BOOKINGS_FILE, []);
}

function saveBookings(bookings) {
  writeJson(BOOKINGS_FILE, bookings);
}

module.exports = {
  loadPitches,
  savePitches,
  loadBookings,
  saveBookings
};
