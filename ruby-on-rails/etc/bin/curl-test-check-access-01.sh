curl -X POST http://localhost:3000/people/1/check_access \
     -H "Content-Type: application/json" \
     -d '{"organization": {"id": "123"}}'
echo

