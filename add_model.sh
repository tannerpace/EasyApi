#!/bin/bash

# Navigate to the project directory
read -p "Enter the path to your project directory: " project_directory
cd "$project_directory" || { echo "Invalid project directory path"; exit 1; }

# Checks if in correct directory with prisma schema
if [ ! -f "prisma/schema.prisma" ]; then
  echo "Prisma schema.prisma file not found in the specified directory."
  exit 1
fi


read -p "Enter the name of the model you want to add: " model_name

# Start model definition
model_definition="model $model_name {\n"

# Loop for adding fields
while true; do
  read -p "Enter field name (or press enter to finish): " field_name
  if [ -z "$field_name" ]; then
    break
  fi
  read -p "Enter type for $field_name (e.g., String, Int, etc.): " field_type
  read -p "Enter attributes for $field_name (e.g., @id, @default(uuid()), leave blank if none): " field_attributes
  
  # Append field definition to model definition
  model_definition="$model_definition  $field_name $field_type $field_attributes\n"
done

# Close model definition
model_definition="$model_definition}\n"

# Append model definition to schema.prisma
echo -e "$model_definition" >> prisma/schema.prisma

echo "Model $model_name added to Prisma schema."


if command -v npx &> /dev/null; then
  echo "Formatting schema.prisma file..."
  npx prisma format
else
  echo "Prisma CLI not found. Consider running 'npx prisma format' manually."
fi
