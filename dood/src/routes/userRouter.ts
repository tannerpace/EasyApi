



import express, { Router, Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

import { updateLastLogin } from '../middleware/authentication';
import prisma from "../middleware/client";
import { hashPassword, verifyPassword } from '../middleware/hash';

interface ParsedToken {
  userData: {
    id: number;
  };
  iat: number;
  exp: number;
}



// Create an instance of the router
const userRouter: Router = express.Router();

// Middleware function to verify the token
const verifyToken = (req: any, res: Response, next: NextFunction) => {
  console.info("hit verify")
  const token = req.cookies.token; // Access the token from the "token" cookie
  console.info("token was ", token)

  if (!token) {
    return res.status(401).json({ error: 'Token not found' });
  }

  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error('JWT secret is not defined');
  }

  try {
    const parsedToken = jwt.verify(token, secret) as ParsedToken;
    req.parsedToken = parsedToken; // Store the parsed token in the request object for later use
    next();
  } catch (err) {
    // if (err.name === 'TokenExpiredError') {
    //   return res.status(401).json({ error: 'Token has expired' });
    // }
    return res.status(500).json({ error: 'Error validating token' });
  }
};


// Example protected route handler
const someProtectedRouteHandler = (req: any, res: Response) => {
  // Access the parsedToken from the request object
  const parsedToken = req.parsedToken;

  // Access the user ID from the parsedToken
  const userId = parsedToken?.userData.id;

  // Perform actions specific to the protected route
  // ...

  // Send a response
  res.json({ message: 'Protected route accessed successfully', userId });
};

// Define the protected route
userRouter.get('/verify', verifyToken, someProtectedRouteHandler);



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




