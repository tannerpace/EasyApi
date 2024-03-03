#!/usr/bin/env node
const { exec } = require('child_process');
const path = require('path');

// Resolve the path to the bash script within the package
const scriptPath = path.resolve(__dirname, '../add_route.sh');

// Execute the bash script
exec(`bash ${scriptPath}`, (error, stdout, stderr) => {
  if (error) {
    console.error(`Error occurred: ${error}`);
    return;
  }
  console.log(`Output: ${stdout}`);
  if (stderr) console.error(`Error: ${stderr}`);
});
