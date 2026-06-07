#!/bin/bash

# Migrations script for MintDev
cd "$MINTDEV_PATH" || exit 1

# Get the last updated timestamp or use a default past date
if [ -f "$MINTDEV_PATH/.last_update" ]; then
    last_updated_at=$(cat "$MINTDEV_PATH/.last_update")
else
    # Default to beginning of time if not set
    last_updated_at=0
fi

echo "Checking for updates..."
# Assuming it's a git repo for users
if [ -d ".git" ]; then
    git pull
fi

echo "Running migrations..."
migrations_run=0

# Iterate through migration scripts
for file in "$MINTDEV_PATH"/migrations/*.sh; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        migrate_at="${filename%.sh}"

        # Only run if it's a number and greater than the last update time
        if [[ "$migrate_at" =~ ^[0-9]+$ ]] && [ "$migrate_at" -gt "$last_updated_at" ]; then
            echo "Running migration for $migrate_at"
            source "$file"
            migrations_run=$((migrations_run+1))
        fi
    fi
done

if [ $migrations_run -eq 0 ]; then
    echo "No new migrations to run."
fi

# Update the timestamp
date +%s > "$MINTDEV_PATH/.last_update"

cd - > /dev/null
