if [ $DayGreet -lt 12 ]; then                                                                 # Time sensitve greetings
  echo "Good morning:" > $SiteReport1                                                         # Also if needed - they are often not, but hay ho
elif [ $DayGreet -lt 18 ]; then
  echo "Good afternoon:" > $SiteReport1
else
  echo "Good evening:" > $SiteReport1
fi
  echo " " > $SiteReport1
