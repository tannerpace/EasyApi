# Tankit 

## Node.js + Prisma + MySQL Project Setup Script


## Overview

TankIt is a powerful NPM package designed to bootstrap Node.ts applications, focusing on the quick setup of APIs using MySQL and Prisma ORM. It provides developers with a suite of scripts that automate the tedious aspects of initial project setup, including project structure creation, route and model generation, and database configuration. TankIt aims to streamline the development process, allowing developers to concentrate on writing business logic and core functionalities.

## Features

- **Project Initialization (`tankit-init`)**: Sets up a new Node.js TypeScript project with essential configurations and structures for a Prisma-MySQL backend API.
- **Route Addition (`add-route`)**: Simplifies the process of adding new Express routes to your application, complete with CRUD operation templates.
- **Model Addition (`add-model`)**: Automates the addition of new models to your Prisma schema, facilitating quick integration of new database tables and relationships.
- **Compatibility with `prisma-zodifier`**: While not part of TankIt, it's recommended to use `prisma-zodifier` alongside to convert Prisma schemas into Zod schemas, ensuring type-safe APIs.

## Getting Started

### Prerequisites

Before installing TankIt, make sure you have the following installed:
- Node.js
- npm (Node Package Manager)
- Git
- Prisma CLI (for Prisma operations)

### Installation

To install TankIt in your project, run the following command in your terminal:

```bash
npm install tankit
```

### Initializing a New Project

After installing TankIt, you can initialize a new project by running:

```bash
npx tankit-init
```

Follow the prompts to complete the setup. This script will create a new Node.js TypeScript project configured with Express, Prisma, and MySQL.

### Adding a New Route

To add a new route to your project, execute:

```bash
npx add-route
```

You'll be prompted to enter the name of the route and whether it should be protected. The script generates a router file in the specified directory with a template for CRUD operations.

### Adding a New Model

To add a new model to your Prisma schema, use:

```bash
npx add-model
```

Provide the model name and attributes as prompted. The script updates your Prisma schema file with the new model definition.

## Contributing

Contributions to Tankit are welcome! If you have suggestions for improvement or have found a bug, please feel free to open an issue or submit a pull request on our [GitHub repository](https://github.com/tannerpace/EasyApi).

## License

TankIt is MIT licensed. 

## questions 

 For any questions, suggestions, or contributions, please contact me via [GitHub](https://github.com/tannerpace).

Tankit strives to make backend development simpler and more enjoyable. By handling the initial setup and repetitive tasks, it allows developers to focus on creating applications business logic, eliminating tedious setup tasks and time spent writing boilerplate code.