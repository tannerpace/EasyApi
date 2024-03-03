#!/bin/bash

# Prompt for the router name
read -p "Enter the name of the router (e.g., productRouter): " router_name
# Convert first letter to uppercase for the model name
model_name=$(echo "$router_name" | sed -r 's/(^|-)(\w)/\U\2/g' | sed 's/Router//')

# Prompt for protection
read -p "Is this router protected? (yes/no): " is_protected

# Define the router file path
router_file_path="./src/routes/${router_name}.ts"

# Ensure the directory exists
router_dir=$(dirname "$router_file_path")
if [ ! -d "$router_dir" ]; then
  echo "Directory $router_dir does not exist. Creating it..."
  mkdir -p "$router_dir"
fi

# Create the router file
echo "Creating $router_file_path..."

cat <<EOF >"$router_file_path"
import express, { Request, Response } from 'express';
const $router_name = express.Router();

EOF

# Append CRUD operations
cat <<EOF >>"$router_file_path"
// List $model_name
$router_name.get('/', (req: Request, res: Response) => {
    res.status(200).send('List $model_name');
});

// Get $model_name by id
$router_name.get('/:id', (req: Request, res: Response) => {
    res.status(200).send('Get $model_name by id');
});

// Create $model_name
$router_name.post('/', (req: Request, res: Response) => {
    res.status(201).send('Create $model_name');
});

// Update $model_name by id
$router_name.put('/:id', (req: Request, res: Response) => {
    res.status(200).send('Update $model_name by id');
});

// Delete $model_name by id
$router_name.delete('/:id', (req: Request, res: Response) => {
    res.status(200).send('Delete $model_name by id');
});
EOF

# Check if the router is protected
if [[ "$is_protected" == "yes" ]]; then
    # Insert import statement for authentication middleware
    sed -i '3i import { checkUserToken } from "../middleware/authentication";' "$router_file_path"
    # Protect the router
    sed -i 's/$router_name.get(/$router_name.get(checkUserToken, /g' "$router_file_path"
    sed -i 's/$router_name.post(/$router_name.post(checkUserToken, /g' "$router_file_path"
    sed -i 's/$router_name.put(/$router_name.put(checkUserToken, /g' "$router_file_path"
    sed -i 's/$router_name.delete(/$router_name.delete(checkUserToken, /g' "$router_file_path"
fi

# Append export statement
echo -e "\nexport default $router_name;" >> "$router_file_path"

echo "$router_name created successfully."

# Reminder to import the router in the main server file
echo "Don't forget to import and use $router_name in your main server file (e.g., index.ts or app.ts)."
