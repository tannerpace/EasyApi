#!/bin/bash

# Check if git is installed
git_check=$(which git)

if [ -z "$git_check" ]; then
    echo "Git is not installed. Installing now..."

    # Install git
    sudo yum install -y git

    echo "Git installation is completed."
else
    echo "Git is already installed."
fi

# Install NVM (Node Version Manager)
if ! [ -x "$(command -v nvm)" ]; then
    echo "NVM is not installed. Installing now..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

    # Source nvm script to current shell
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    echo "NVM installation is completed."
else
    echo "NVM is already installed."
fi

# Install Node.js 16 using NVM and set it as default
nvm install 16
nvm alias default 16

# Install pnpm
npm install -g pnpm

# Check if mysql is installed
mysql_check=$(which mysql)

if [ -z "$mysql_check" ]; then
    echo "MySQL is not installed. Installing now..."

    # Install mysql server
    sudo yum install -y mysql

    echo "MySQL installation is completed."
else
    echo "MySQL is already installed."
fi

# Setting up root user with password
echo "Setting up MySQL root user..."

sudo mysql -u root <<-EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;
EOF

echo "Root user setup completed."
