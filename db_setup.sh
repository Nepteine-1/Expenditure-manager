sqlite3 database/database < database/data_test.sql
if [ $? -eq 0 ]; then
    echo "Database updated successfully"
fi
