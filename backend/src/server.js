const http = require('http');
const { URL } = require('url');
const crypto = require('crypto');

const {
  loadPitches,
  savePitches,
  loadBookings,
  saveBookings
} = require('./storage');
const { validatePitch, validateBooking } = require('./validation');

const PORT = process.env.PORT || 4000;

function createId(prefix) {
  const random = typeof crypto.randomUUID === 'function'
    ? crypto.randomUUID()
    : crypto.randomBytes(8).toString('hex');
  return `${prefix}-${random}`;
}

function sendJson(res, statusCode, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,PATCH,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  });
  res.end(body);
}

function handleOptions(req, res) {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET,POST,PATCH,OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
    res.end();
    return true;
  }
  return false;
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', chunk => {
      data += chunk.toString();
      if (data.length > 1e6) {
        reject(new Error('Payload too large'));
        req.destroy();
      }
    });
    req.on('end', () => {
      if (!data) {
        resolve({});
        return;
      }
      try {
        resolve(JSON.parse(data));
      } catch (error) {
        reject(new Error('Invalid JSON body'));
      }
    });
    req.on('error', reject);
  });
}

function findBooking(bookings, bookingId) {
  return bookings.find(item => item.id === bookingId);
}

function getPathSegments(pathname) {
  return pathname
    .split('/')
    .filter(Boolean);
}

const server = http.createServer(async (req, res) => {
  if (handleOptions(req, res)) {
    return;
  }

  const pitches = loadPitches();
  const bookings = loadBookings();

  const requestUrl = new URL(req.url, `http://${req.headers.host}`);
  const segments = getPathSegments(requestUrl.pathname);

  try {
    if (req.method === 'GET' && requestUrl.pathname === '/api/pitches') {
      sendJson(res, 200, { data: pitches });
      return;
    }

    if (req.method === 'POST' && requestUrl.pathname === '/api/pitches') {
      const payload = await parseBody(req);
      const { valid, errors, data } = validatePitch(payload);
      if (!valid) {
        sendJson(res, 422, { errors });
        return;
      }

      const newPitch = {
        id: createId('pitch'),
        ...data,
        createdAt: new Date().toISOString()
      };
      pitches.push(newPitch);
      savePitches(pitches);
      sendJson(res, 201, { data: newPitch });
      return;
    }

    if (req.method === 'GET' && requestUrl.pathname === '/api/bookings') {
      const { searchParams } = requestUrl;
      const pitchId = searchParams.get('pitchId');
      const date = searchParams.get('date');

      const filtered = bookings.filter(item => {
        if (pitchId && item.pitchId !== pitchId) {
          return false;
        }
        if (date && item.date !== date) {
          return false;
        }
        return true;
      });

      sendJson(res, 200, { data: filtered });
      return;
    }

    if (req.method === 'POST' && requestUrl.pathname === '/api/bookings') {
      const payload = await parseBody(req);
      const pitch = pitches.find(item => item.id === payload.pitchId);
      const { valid, errors, data } = validateBooking(payload, pitch);
      if (!valid) {
        sendJson(res, 422, { errors });
        return;
      }

      const conflict = bookings.find(item =>
        item.pitchId === pitch.id &&
        item.date === data.date &&
        item.slot === data.slot &&
        item.status !== 'cancelled'
      );
      if (conflict) {
        sendJson(res, 409, { errors: ['هذا الموعد محجوز بالفعل.'] });
        return;
      }

      const newBooking = {
        id: createId('booking'),
        pitchId: pitch.id,
        ...data,
        status: 'pending',
        createdAt: new Date().toISOString()
      };
      bookings.push(newBooking);
      saveBookings(bookings);
      sendJson(res, 201, { data: newBooking });
      return;
    }

    if (req.method === 'GET' && segments[0] === 'api' && segments[1] === 'bookings' && segments.length === 3) {
      const booking = findBooking(bookings, segments[2]);
      if (!booking) {
        sendJson(res, 404, { errors: ['الحجز غير موجود.'] });
        return;
      }
      sendJson(res, 200, { data: booking });
      return;
    }

    if (
      req.method === 'PATCH' &&
      segments[0] === 'api' &&
      segments[1] === 'bookings' &&
      segments.length === 4 &&
      segments[3] === 'status'
    ) {
      const bookingId = segments[2];
      const booking = findBooking(bookings, bookingId);
      if (!booking) {
        sendJson(res, 404, { errors: ['الحجز غير موجود.'] });
        return;
      }

      const payload = await parseBody(req);
      const nextStatus = payload.status;
      const allowedStatuses = ['pending', 'confirmed', 'cancelled'];
      if (!allowedStatuses.includes(nextStatus)) {
        sendJson(res, 422, { errors: ['حالة غير صحيحة.'] });
        return;
      }

      booking.status = nextStatus;
      booking.statusUpdatedAt = new Date().toISOString();
      saveBookings(bookings);
      sendJson(res, 200, { data: booking });
      return;
    }

    sendJson(res, 404, { errors: ['المسار غير موجود.'] });
  } catch (error) {
    console.error(error);
    sendJson(res, 500, { errors: ['حدث خطأ غير متوقع في الخادم.'] });
  }
});

server.listen(PORT, () => {
  console.log(`API server is running on http://localhost:${PORT}`);
});
