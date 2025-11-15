const ISO_DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function ensureArray(value) {
  if (Array.isArray(value)) {
    return value;
  }
  return [];
}

function validatePitch(payload = {}) {
  const errors = [];

  if (!isNonEmptyString(payload.name)) {
    errors.push('الاسم مطلوب.');
  }

  if (!isNonEmptyString(payload.location)) {
    errors.push('المكان مطلوب.');
  }

  const price = Number(payload.pricePerHour);
  if (!Number.isFinite(price) || price <= 0) {
    errors.push('سعر الساعة يجب أن يكون رقمًا أكبر من صفر.');
  }

  const surfaceType = isNonEmptyString(payload.surfaceType)
    ? payload.surfaceType
    : 'Artificial Turf';

  const amenities = ensureArray(payload.amenities).filter(isNonEmptyString);
  const slots = ensureArray(payload.slots).filter(isNonEmptyString);
  if (slots.length === 0) {
    errors.push('يجب تحديد مواعيد متاحة واحدة على الأقل.');
  }

  return {
    valid: errors.length === 0,
    errors,
    data: {
      name: payload.name?.trim(),
      location: payload.location?.trim(),
      pricePerHour: price,
      surfaceType,
      amenities,
      slots
    }
  };
}

function validateBooking(payload = {}, pitch) {
  const errors = [];

  if (!pitch) {
    errors.push('الملعب غير موجود.');
  }

  if (!isNonEmptyString(payload.customerName)) {
    errors.push('اسم العميل مطلوب.');
  }

  if (!isNonEmptyString(payload.customerPhone)) {
    errors.push('رقم التواصل مطلوب.');
  }

  if (!ISO_DATE_REGEX.test(payload.date || '')) {
    errors.push('التاريخ يجب أن يكون بالصيغة YYYY-MM-DD.');
  }

  if (!isNonEmptyString(payload.slot)) {
    errors.push('يجب اختيار الموعد المطلوب حجزه.');
  } else if (pitch && !pitch.slots.includes(payload.slot)) {
    errors.push('الموعد غير متاح لهذا الملعب.');
  }

  return {
    valid: errors.length === 0,
    errors,
    data: {
      customerName: payload.customerName?.trim(),
      customerPhone: payload.customerPhone?.trim(),
      date: payload.date,
      slot: payload.slot
    }
  };
}

module.exports = {
  validatePitch,
  validateBooking
};
