const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');
require('dotenv').config();

const { User, Song, sequelize } = require('../models');

const seedAdmin = async () => {
  const adminEmail = (process.env.ADMIN_EMAIL || 'admin').trim().toLowerCase();
  const adminPassword = process.env.ADMIN_PASSWORD || 'admin';
  const adminName = process.env.ADMIN_NAME || 'admin';
  const hashedPassword = await bcrypt.hash(adminPassword, 10);

  const existingAdmin = await User.findOne({ where: { email: adminEmail } });
  if (existingAdmin) {
    await existingAdmin.update({
      name: adminName,
      password: hashedPassword,
      role: 'admin',
    });
    return { created: false, email: adminEmail };
  }

  await User.create({
    name: adminName,
    email: adminEmail,
    password: hashedPassword,
    role: 'admin',
  });
  return { created: true, email: adminEmail };
};

const seedSongs = async () => {
  const songsDir = path.join(__dirname, '..', 'songs');
  const files = fs
    .readdirSync(songsDir)
    .filter((file) => file.endsWith('.json'))
    .sort((a, b) => Number.parseInt(a, 10) - Number.parseInt(b, 10));

  let created = 0;
  let updated = 0;

  for (const file of files) {
    const filePath = path.join(songsDir, file);
    const songData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    const id = Number(songData.number || file.replace('.json', ''));

    if (!Number.isInteger(id)) {
      continue;
    }

    const payload = {
      id,
      title: songData.title || `Song ${id}`,
      category: songData.category || 'Unknown',
      content: { sections: Array.isArray(songData.sections) ? songData.sections : [] },
    };

    const existingSong = await Song.findByPk(id);
    if (existingSong) {
      await existingSong.update(payload);
      updated += 1;
    } else {
      await Song.create(payload);
      created += 1;
    }
  }

  return { total: files.length, created, updated };
};

const seedAll = async () => {
  try {
    await sequelize.authenticate();
    await sequelize.sync();

    const adminResult = await seedAdmin();
    const songsResult = await seedSongs();

    console.log('Seeding complete');
    console.log(`Admin: ${adminResult.created ? 'created' : 'updated'} (${adminResult.email})`);
    console.log(
      `Songs: ${songsResult.total} processed (${songsResult.created} created, ${songsResult.updated} updated)`
    );
  } catch (error) {
    console.error('Seeding failed:', error.message);
    process.exitCode = 1;
  } finally {
    await sequelize.close();
  }
};

if (require.main === module) {
  seedAll();
}

module.exports = seedAll;
