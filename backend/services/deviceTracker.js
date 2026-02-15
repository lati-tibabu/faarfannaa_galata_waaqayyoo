const crypto = require('crypto');
const { DeviceConnection } = require('../models');

const normalizeIpAddress = (rawIp) => {
  if (!rawIp) {
    return 'unknown';
  }
  if (rawIp.startsWith('::ffff:')) {
    return rawIp.replace('::ffff:', '');
  }
  return rawIp;
};

const resolveDeviceId = (req) => {
  const providedDeviceId = req.header('x-device-id');
  if (providedDeviceId && providedDeviceId.trim()) {
    return providedDeviceId.trim().slice(0, 128);
  }

  const fingerprint = `${req.header('user-agent') || 'unknown'}|${req.ip || req.socket?.remoteAddress || 'unknown'}`;
  return crypto.createHash('sha256').update(fingerprint).digest('hex');
};

const trackDeviceConnection = async (req, userId) => {
  try {
    const deviceId = resolveDeviceId(req);
    const now = new Date();
    const userAgent = (req.header('user-agent') || 'Unknown').slice(0, 2000);
    const ipAddress = normalizeIpAddress(req.ip || req.socket?.remoteAddress || 'unknown');

    const existingDevice = await DeviceConnection.findOne({ where: { deviceId } });
    if (existingDevice) {
      await existingDevice.update({
        userId: userId || existingDevice.userId,
        userAgent,
        ipAddress,
        lastSeenAt: now,
      });
      return;
    }

    await DeviceConnection.create({
      deviceId,
      userId: userId || null,
      userAgent,
      ipAddress,
      firstSeenAt: now,
      lastSeenAt: now,
    });
  } catch (error) {
    console.error('Unable to track device connection:', error.message);
  }
};

module.exports = {
  trackDeviceConnection,
};
