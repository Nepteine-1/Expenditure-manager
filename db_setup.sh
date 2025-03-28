sqlite3 Database/database < Database/data_test.sql
if [ $? -eq 0 ]; then
    echo "Database updated successfully"
fi
