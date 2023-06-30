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
# if mysql_username is empty, use root
if [ -z "$mysql_username" ]
then
  mysql_username=root
fi
  
read -sp "Enter MySQL password: " mysql_password
# if mysql_password is empty, use password
if [ -z "$mysql_password" ]
then
  mysql_password=password
fi

read -p "Enter the name of the new MySQL database or leave blank to default it to project name: " database_name

# if database_name is empty, use the project_name
if [ -z "$database_name" ]
then
  database_name=$project_name
fi

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
  salt           String?
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


# Adding a single prisma instance
cat << EOF > src/middleware/client.ts
import { PrismaClient } from '@prisma/client'

const prisma: PrismaClient = new PrismaClient()

// if (process.env.NODE_ENV === 'production') {
//   prisma = new PrismaClient()
// }

// if (!prisma) {
//   prisma = new PrismaClient()
// }



export default prisma
EOF

# Adding hash MiddleWarwes
cat << EOF > src/middleware/hash.ts
import crypto from 'crypto';

interface IHashedPassword {
  salt: string;
  hashedPassword: string;
}

const hashPassword = (password: string, salt = crypto.randomBytes(16).toString('hex')): IHashedPassword => {
  const hashedPassword = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return { salt, hashedPassword };
}

const verifyPassword = (password: string, hashedPassword: string, salt: string): boolean => {
  const passwordData = hashPassword(password, salt);
  return passwordData.hashedPassword === hashedPassword;
}

export {
  hashPassword,
  verifyPassword
}

EOF

# Adding  authentication Middlewares
cat << EOF > src/middleware/authentication.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

import prisma from './client';

interface ParsedToken {
  userData: {
    id: number;
  };
  iat: number;
  exp: number;
}

interface RequestWithUser extends Request {
  user: {
    id: number;
    refresh_token: string | null;
  };
  parsedToken: ParsedToken;
}

const checkUserToken = async (req: RequestWithUser, res: Response, next: NextFunction) => {
  try {
    const token = req.headers.authorization;
    if (!token) {
      return res.status(401).json({ error: 'JWT must be provided' });
    }

    const parsedToken = verifyToken(token);
    if (!parsedToken) {
      throw new Error('Invalid token');
    }

    req.parsedToken = parsedToken;

    const user = await getUserFromToken(parsedToken);
    if (!user || !user.refresh_token) {
      return res
        .status(401)
        .json({ error: 'No user found for this token or refresh token is not set' });
    }

    req.user = user;
    await updateLastLogin(user.id);

    // Set the token as a cookie
    const secret = process.env.JWT_SECRET;
    if (!secret) {
      throw new Error('JWT secret is not defined');
    }
    const cookieOptions = {
      httpOnly: true,
      maxAge: 3600000, // 1 hour
      // secure: true, // Enable this option for secure (HTTPS) connections only
    };
    const tokenCookie = jwt.sign({ userData: { id: user.id } }, secret, { expiresIn: '1h' });
    res.cookie('token', tokenCookie, cookieOptions);

  } catch (err) {
    return handleError(err as Error, res);
  }

  next();
};

const verifyToken = (token: string): ParsedToken | null => {
  if (
    typeof token !== 'string' ||
    !/^Bearer [a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+$/.test(token)
  ) {
    return null;
  }

  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error('JWT secret is not defined');
  }

  try {
    return jwt.verify(token.split(' ')[1], secret) as ParsedToken;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (err: any) {
    if (err.name === 'TokenExpiredError') {
      throw new Error('Token has expired');
    }
    throw new Error('Error validating token');
  }
};

const getUserFromToken = async (
  parsedToken: ParsedToken
): Promise<{ id: number; refresh_token: string | null }> => {
  if (typeof parsedToken.userData.id !== 'number') {
    throw new Error('Invalid user ID in token');
  }

  return (await prisma.user.findFirst({
    where: {
      id: parsedToken.userData.id,
    },
    select: { id: true, refresh_token: true },
  })) as { id: number; refresh_token: string | null };
};

const updateLastLogin = async (userId: number): Promise<void> => {
  await prisma.user
    .update({
      where: { id: userId },
      data: { last_login: new Date() },
    })
    .catch((err) => {
      // eslint-disable-next-line no-console
      console.log('Error updating last login ', err);
      throw new Error('Error updating last login');
    });
};

const handleError = (err: Error, res: Response): Response => {
  console.error(err);
  if (err.message === 'Token has expired') {
    return res.status(401).json({ error: err.message });
  }
  return res.status(500).json({ error: 'Error occurred' });
};

export {
  updateLastLogin,
  checkUserToken,
  verifyToken,
  getUserFromToken,
  handleError
};
EOF




# Creating a user router
cat << EOF > src/routes/userRouter.ts


import express, { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';

import { updateLastLogin } from '../middleware/authentication';
import prisma from "../middleware/client";
import { hashPassword, verifyPassword } from '../middleware/hash';

const userRouter: Router = express.Router();

// GET /user
userRouter.get('/', (req, res) => {
  res.json({ message: 'Hello user' });
});

// POST /user (user registration)
userRouter.post('/', async (req, res) => {
  const { firstName, lastName, email, password } = req.body;
  try {
    const { salt, hashedPassword } = hashPassword(password);
    const user = await prisma.user.create({
      data: {
        first_name: firstName,
        last_name: lastName,
        email,
        password: hashedPassword,
        salt: salt,
      },
    });
    res.json({
      message: 'User created',
      user: {
        firstName: user.first_name,
        lastName: user.last_name,
        email: user.email,
      },
    });
  } catch (error) {
    res.json({ message: 'User not created' });
  }
});

userRouter.post('/login', async (req: Request, res: Response) => {
  const { email, password } = req.body;
  try {
    const user = await prisma.user.findUnique({
      where: {
        email,
      },
      select: { id: true, salt: true, password: true },
    });
    if (user && user.salt && user.password) {
      if (verifyPassword(password, user.password, user.salt)) {
        console.info('User logged in');

        // Generate a JWT for the user
        const secret = process.env.JWT_SECRET;
        if (!secret) {
          throw new Error('JWT secret is not defined');
        }
        const token = jwt.sign({ userData: { id: user.id } }, secret, { expiresIn: '1h' });

        // update last login
        await updateLastLogin(user.id);

        res
          .cookie('token', token, { httpOnly: true, maxAge: 3600000 }) // Set the token as an HTTP-only cookie
          .json({ message: 'User logged in', token });
      } else {
        console.info('Wrong password');
        res.status(401).json({ message: 'Wrong password' });
      }
    } else {
      console.info('User not found');
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Something went wrong', error });
  }
});

export default userRouter;


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
