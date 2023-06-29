#!/bin/bash

read -p "Enter the name of your project: " project_name
read -p "Enter the path where you want to create the project (leave empty for current directory): " project_path
# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is required for this script to work."
    read -p "Do you want to install jq? [Y/n] " answer

    # Default to 'Yes' if the user simply hits the <Enter> key
    answer=${answer:-Y}

    if [[ $answer =~ ^[Yy]$ ]]
    then
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null
        then
            echo "Homebrew is required to install jq."
            read -p "Do you want to install Homebrew? [Y/n] " answer

            # Default to 'Yes' if the user simply hits the <Enter> key
            answer=${answer:-Y}

            if [[ $answer =~ ^[Yy]$ ]]
            then
                echo "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            else
                echo "Homebrew is not installed. Exiting..."
                exit 1
            fi
        fi

        echo "Installing jq..."
        brew install jq
    else
        echo "jq is not installed. Exiting..."
        exit 1
    fi
fi

# if project_path is empty, use the current directory
if [ -z "$project_path" ]
then
  project_path="."
fi

project_directory_path="$project_path/$project_name"

echo "Creating project directory in $project_directory_path..."
mkdir -p $project_directory_path
cd $project_directory_path

read -p "Enter MySQL username: " mysql_username
read -sp "Enter MySQL password: " mysql_password
read -p "Enter the name of the new MySQL database: " database_name

echo "Initializing a new Node.js project..."
pnpm init 

echo "Installing necessary dependencies..."
pnpm install express jsonwebtoken express-jwt helmet cors dotenv prisma typescript ts-node @types/node

echo "Installing necessary devDependencies..."
pnpm install -D @types/express @types/node @types/jsonwebtoken @types/cors ts-node typescript nodemon

echo "Prisma via npx"
npx prisma

echo "Initializing Prisma..."
npx prisma init --datasource-provider mysql

echo "Writing database connection URL to .env file..."
echo "DATABASE_URL=\"mysql://$mysql_username:$mysql_password@localhost:3306/$database_name\"" > .env


echo "Adding User model to Prisma schema..."

cat << EOF >> prisma/schema.prisma

enum Role {
  GUEST
  USER
  ADMIN
  SUPERADMIN
  API_USER
}


model User {
  id             Int      @id @default(autoincrement())
  email          String   @unique
  first_name     String?
  last_name      String?
  user_name      String?
  password       String?
  token          String?
  refresh_token  String?
  last_login     DateTime?
  role           Role     @default(USER)
}
EOF


echo "User model added to Prisma schema."


echo "Installing ESLint, Prettier and related plugins..."
pnpm install -D eslint prettier eslint-plugin-prettier eslint-config-prettier eslint-plugin-node eslint-config-node @typescript-eslint/eslint-plugin @typescript-eslint/parser @babel/eslint-parser

echo "Configuring ESLint..."
cat << EOF > .eslintrc.js
module.exports = {
  env: {
    es2021: true,
    node: true,
  },
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
    root: true,
    allowImportExportEverywhere: true,
  },
  plugins: ["@typescript-eslint", "import"],
  rules: {
    "@typescript-eslint/ban-ts-comment": 1,
    "no-console": ["error", { allow: ["warn", "error", "info"] }],
    "spaced-comment": "error",
    "no-unused-vars": "warn",
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/array-type": ["error", { default: "array" }],
    "import/no-anonymous-default-export": ["error"],
    "import/order": [
      "error",
      {
        groups: ["builtin", "external", "internal", "parent", "sibling", "index"],
        "newlines-between": "always",
        alphabetize: {
          order: "asc",
          caseInsensitive: true,
        },
      },
    ],
    "import/first": "error",
    "import/newline-after-import": "error",
    "import/no-duplicates": "error"
  },
}
EOF

echo "Configuring Prettier..."
cat << EOF > .prettierrc.json
{ "singleQuote": true, "parser": "typescript" }
EOF

echo "Configuring TypeScript..."
cat << EOF > tsconfig.json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "display": "Default",
  "compilerOptions": {
    "composite": false,
    "declaration": true,
    "declarationMap": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "inlineSources": false,
    "isolatedModules": true,
    "moduleResolution": "node",
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "preserveWatchOutput": true,
    "skipLibCheck": true,
    "lib": ["es6", "dom"],
    "module": "CommonJS",
    "target": "ES2021",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "baseUrl": "src",
    "paths": {
      "@/*": ["*"]
    }
  },
  "exclude": ["node_modules"],
  "include": ["src"]
}
EOF


# echo "Updating prisma/schema.prisma file with MySQL datasource..."
# sed -i -e 's|url = ".*"|url = env("DATABASE_URL")|g' prisma/schema.prisma
# sed -i -e 's/provider = ".*"/provider = "mysql"/g' prisma/schema.prisma

echo "Generating Prisma client..."
npx prisma migrate dev --name init

echo "Creating directory structure..."
mkdir src
mkdir src/controllers
mkdir src/middleware
mkdir src/routes
mkdir src/models
mkdir src/utils

# Creating a user router
cat << EOF > src/routes/userRouter.ts
import express, { Router } from 'express';

const userRouter: Router = express.Router();

// GET /user
userRouter.get('/', (req, res) => {
  res.json({ message: 'Hello user' });
});

export default userRouter
EOF

echo "Generating JWT secret..."
jwt_secret=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")

echo "Creating .env file with JWT secret..."
echo "JWT_SECRET=$jwt_secret" >> .env

echo "Creating MySQL database..."
mysql -u $mysql_username -p$mysql_password -e "CREATE DATABASE $database_name;"

echo "Creating a basic Express server in index.ts file..."
cat << EOF > src/index.ts
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import userRouter from './routes/userRouter';

const app = express();
const port = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());
app.use(express.json());

app.use('/user', userRouter);

app.get('/health', (req, res) => {
  res.json({
    status: 'UP',
    timestamp: Date.now()
  });
});

app.listen(port, () => {
  console.log(\`Server is running on port \${port}\`);
});
EOF

echo "Updating package.json with the new script..."
jq '.scripts.dev = "nodemon ./src/index.ts"' package.json > temp.json && mv temp.json package.json

echo "starting the server"
pnpm run dev

echo "Setup completed."
