const { User } = require('../models');
const bcrypt = require('bcrypt');
require('dotenv').config();

const seedAdmin = async () => {
  try {
    const adminEmail = process.env.ADMIN_EMAIL || 'admin@example.com';
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';
    const adminName = process.env.ADMIN_NAME || 'Admin User';

    const existingAdmin = await User.findOne({ where: { email: adminEmail } });
    if (existingAdmin) {
      console.log('Admin user already exists');
      return;
    }

    const hashedPassword = await bcrypt.hash(adminPassword, 10);
    const admin = await User.create({
      name: adminName,
      email: adminEmail,
      password: hashedPassword,
      role: 'admin'
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