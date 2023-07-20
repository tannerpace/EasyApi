# Node.js + Prisma + MySQL Project Setup Script

This script is a bash script used to automatically generate a new project using Node.js, Prisma ORM, and MySQL database. The script includes necessary configurations for TypeScript, Prettier, and ESLint. It also generates a basic user authentication mechanism with hashed passwords.

The script does the following in order:

1. Prompts the user for project name and path.
2. Checks for the presence of `jq`, a command-line JSON processor. If not present, the script offers to install it.
3. Checks for the directory where the project should be created. If the user does not provide one, the script uses the current directory.
4. Prompts the user for MySQL credentials and database name. If not provided, the script uses default values.
5. Creates a new Node.js project using `pnpm init`.
6. Installs required project dependencies and devDependencies, including Express, jsonwebtoken, Prisma, TypeScript, and more.
7. Initializes Prisma with MySQL as the data source provider.
8. Writes the database connection URL to a `.env` file.
9. Adds a `User` model to Prisma's schema file.
10. Installs and configures ESLint and Prettier for code formatting and linting.
11. Configures TypeScript for the project.
12. Generates Prisma client using `npx prisma migrate dev --name init`.
13. Creates the necessary directory structure for the project.
14. Adds middleware for a single Prisma instance, password hashing, and authentication.
15. Creates a user router for user-related routes.

The script also has necessary error checks in place to ensure that operations are successful before proceeding to the next step.

## Prerequisites

The script requires the following installed on your machine:

- Node.js and npm
- jq
- Homebrew
- pnpm
- MySQL server

## Usage

- Download or clone the bash script to your local machine.
- Run the script using the command `bash init_project.sh`.

The script will guide you through the rest of the process via prompts.

## Note

This script assumes you are using macOS or a Linux-based operating system. For other operating systems, you may need to modify the script to match your environment.

## Caution

The script will install packages globally on your machine if they are not found, including `jq` and `Homebrew`. Make sure you are comfortable with this before running the script.

## Contribution

Contributions are always welcome! Please submit a PR if you have any improvements or feature additions.

