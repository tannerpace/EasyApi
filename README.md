# Node.js Project Initialization Script

This script is designed to streamline the process of creating a new Node.js project. It automates the creation of a project folder, a MySQL database, a `.env` file, as well as setting up the fundamental file structure. By doing so, it helps developers to rapidly get started on their new Node.js project.

## How to Use:

### Step 1: Execute the Script

Run the script in your terminal by entering:

```
./init_project.sh
```

### Step 2: Follow the On-Screen Prompts

You'll be guided to provide several key inputs:

- **Project Name**: This will be the name of your project folder.
- **Database Name**: The script will create a new MySQL database with this name.
- **User Name**: This will be the name of the user that has access to the designated database.
- **User Password**: This will be the password for the user that has access to the designated database.

Upon receiving these inputs, the script will execute the following tasks:

- Create a project folder using the provided name.
- Install the necessary dependencies.
- Generate a `.env` file with the provided database, user, and password information.
- Create a MySQL database with the provided name.
- Create the basic file structure for a Node.js project.
- Start the server.

After completion, your new Node.js project is ready for you to start coding!

## That's It!

Your development environment is now set up and ready for you to jump into coding your new Node.js project.

## You can make changes to the script to suit your needs.

## after running the script you can make changes to the schema.prisma file and run the following commands to update the database

```
npx prisma migrate dev --name [your  migration name]
```
