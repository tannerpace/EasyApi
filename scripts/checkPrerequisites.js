const execSync = require('child_process').execSync;

try {
  execSync('prisma --version', { stdio: 'ignore' });
  console.log('Prisma CLI is installed. You are ready to go!');
} catch (error) {
  console.error('Prisma CLI is not installed. Please install it by running `npm install @prisma/cli --save-dev`.');
}
