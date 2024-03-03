#!/usr/bin/env node

const inquirer = require('inquirer');
const fs = require('fs-extra');
const path = require('path');


function generateRouteContent(name, isProtected) {

  const protectMiddleware = isProtected ? `const verifyToken = require('../middleware/verifyToken');` : '';
  const protectionCode = isProtected ? 'verifyToken,' : '';

  const routeContent = `import express from 'express';
  ${protectMiddleware}

const router = express.Router();

// List route
router.get('/', ${protectionCode} (req, res) => {
  res.send('Listing all ${name}...');
});

// Create route
router.post('/', ${protectionCode} (req, res) => {
  res.send('Creating a new ${name}...');
});

// Update route
router.put('/:id', ${protectionCode} (req, res) => {
  res.send('Updating a ${name}...');
});

// Delete route
router.delete('/:id', ${protectionCode} (req, res) => {
  res.send('Deleting a ${name}...');
});

export default router;
`;

  return routeContent;
}

async function addRoute() {
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'routeName',
      message: 'Enter the name for the new route:',
    },
    {
      type: 'confirm',
      name: 'isProtected',
      message: 'Should this route be protected?',
      default: false,
    },
  ]);

  const { routeName, isProtected } = answers;
  const routeContent = generateRouteContent(routeName, isProtected);
  const filePath = path.join(process.cwd(), 'src', 'routes', `${routeName}Router.js`);

  await fs.outputFile(filePath, routeContent);
  console.log(`Route ${routeName} created at ${filePath}`);
}


addRoute().catch(error => console.error(error));
