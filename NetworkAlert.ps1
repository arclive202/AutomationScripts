$date = $args[0]
$counter = $args[1]
$threshold = $args[2]
$value = $args[3]

$time =  get-date
echo "TIME: $time `t`t DATE: `t $date `t Counter: `t $Counter `t Threshold: `t $threshold `t Value: `t $value`n`n`n" | out-file "C:\Users\aditya.roychoudhary\Desktop\SQLQuery\networkalert.txt" -append