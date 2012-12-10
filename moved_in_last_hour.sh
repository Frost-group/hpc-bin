echo "In Last 24hrs..."
w | grep -v days
echo "In Last Hour..."
w | grep -v days | grep -v m\  
