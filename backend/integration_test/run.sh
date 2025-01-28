#!/bin/bash

# Start the database container in detached mode
docker compose up -d flask_db_integration

# Create a database named 'test'
docker compose exec flask_db_integration psql -U postgres -c "CREATE DATABASE test;"

sleep 5

# Now start the Flask application
docker compose up -d flask_app_integration

# Run integration tests
TEST_RESULT=$(docker compose run --rm integration_tests)

# Capture the exit code
EXIT_CODE=$?


# Check if tests passed or failed.
if [ $EXIT_CODE -eq 0 ]; then
    echo "Integration tests passed successfully!"
else
    echo "Integration tests failed!"

    # Print logs from the integration_tests container.
    echo "Integration test logs:"
    docker compose logs integration_tests  # Fetch and print logs for the integration_tests service.
fi

exit $EXIT_CODE
