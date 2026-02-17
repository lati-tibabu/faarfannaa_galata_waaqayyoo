const { User } = require('../models');
const bcrypt = require('bcrypt');
require('dotenv').config();

const seedAdmin = async () => {
  try {
    const adminEmail = (process.env.ADMIN_EMAIL || 'admin').trim().toLowerCase();
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin';
    const adminName = process.env.ADMIN_NAME || 'admin';

    const existingAdmin = await User.findOne({ where: { email: adminEmail } });

    if (existingAdmin) {
      const hasDefaultPassword = await bcrypt.compare(adminPassword, existingAdmin.password);
      const updates = {};

      if (existingAdmin.name !== adminName) {
        updates.name = adminName;
      }
      if (existingAdmin.role !== 'admin') {
        updates.role = 'admin';
      }

      // Keep enforcing first-login until default password is changed.
      if (existingAdmin.first_login !== hasDefaultPassword) {
        updates.first_login = hasDefaultPassword;
      }

      if (Object.keys(updates).length > 0) {
        await existingAdmin.update(updates);
      }

      console.log('Admin user exists:', existingAdmin.email);
      return;
    }

    const hashedPassword = await bcrypt.hash(adminPassword, 10);
    const admin = await User.create({
      name: adminName,
      email: adminEmail,
      password: hashedPassword,
      role: 'admin',
      first_login: true,
    });

    console.log('Admin user created:', admin.email);
  } catch (error) {
    console.error('Error seeding admin:', error);
  }
};

if (require.main === module) {
  seedAdmin().then(() => process.exit(0));
}

module.exports = seedAdmin;
