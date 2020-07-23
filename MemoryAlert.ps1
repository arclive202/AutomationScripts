$percentval = $args[0]

$time =  get-date
echo "The time of alert generation is $time `n And the percentage of memory utilisation is $percentval `n`n" | out-file "C:\Users\aditya.roychoudhary\Desktop\SQLQuery\memoryalert.txt" -append