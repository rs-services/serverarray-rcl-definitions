define scale_up($count) do
    # Launch $count instances in the array
    $i = 0
    while $i < $count do
        @@array.launch()
        $i = $i + 1
    end
    # Add tag to change the scaled_state
    rs_cm.tags.multi_add(resource_hrefs:[@@array.href], tags:["array:scale_state=scaled_up"])    
end
define scale_down($count) do
    # Terminate $count instances in the array
    $i = 1
    @instances = @@array.current_instances()
    while $i <= $count do
        @instance = @instances[size(@instances)-$i]
        @instance.terminate()
        $i = $i + 1
    end
    # Add tag to change the scaled_state
    rs_cm.tags.multi_add(resource_hrefs:[@@array.href], tags:["array:scale_state=scaled_down"])    
end
define monitor() do
    # In this example, we will scale up the array every hour for 15 minutes [from *:30 -> *:45] during that hour.
    # We use tag "array:scale_state=..." to store whether array is "scaled_up" or "scaled_down" each time monitor() runs

    # Get Array Object Details so we can use the resize_up_by and resize_down_by scaling parameters later
    @@array = @@array.get()
    $array_object = to_object(@@array)
    # Get current minute from time and convert to number object type
    $time_now = now()
    $minute = to_n(strftime($time_now, "%M")) 
    # Get current scale_state from array tag value
    $scale_state=tag_value(@@array, "array:scale_state") 
    

    # Check if current time between *:30 and *:45 AND scale_state != scaled_up
    if (($minute >= 30 && $minute <= 45) && ($scale_state != "scaled_up"))
        # Get pacing scaling_up value from Array configuration
        $resize_up_by = to_n($array_object["details"][0]["elasticity_params"]["pacing"]["resize_up_by"])
        # Do the scale_up operation
        call scale_up($resize_up_by)
    # Else scale down if scale_state != scaled_down and time is not 30<n<45
    elsif (!($minute >= 30 && $minute <= 45) && ($scale_state != "scaled_down"))
        # Get pacing scaling_down value from Array configuration
        $resize_down_by = to_n($array_object["details"][0]["elasticity_params"]["pacing"]["resize_down_by"])
        # Do the scale_down operation
        call scale_down($resize_down_by)
    end
end
