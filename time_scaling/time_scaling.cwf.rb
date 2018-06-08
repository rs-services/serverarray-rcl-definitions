define scale_up($params) do
    #call rs__log("Starting Scale Up")
    @@array.launch()
    #call rs__log("Completed Scale Up")
end
define scale_down($params) do
    #call rs__log("Starting Scale Down")
    # Get all instance objects in array
    @instances = @@array.current_instances()
    # Select last instance object in array [newest instance]
    @instance = @instances[size(@instances)-1]
    # Terminate instance selected
    @instance.terminate()
end
define monitor() do
    # In this example, we will scale up the array every hour for 15 minutes [from *:30 -> *:45] during that hour.
    # We use tag "array:scale_state=..." to store whether array is "scaled_up" or "scaled_down" each time monitor() runs

    # Get current minute from time and convert to number object type
    $time_now = now()
    $minute = to_n(strftime($time_now, "%M")) 
    # Get current scale_state from array tag value
    $scale_state=tag_value(@@array, "array:scale_state") 

    # scale_up and scale_down require params, but we don't use them so we create an empty param object.
    $params = {} 

    # Scale up current time between *:30 and *:45 AND scale_state != scaled_up
    if (($minute >= 30 && $minute <= 45) && ($scale_state != "scaled_up"))
        # Do the scale_up operation
        call scale_up($params)
        # Add tag to change the scaled_state
        rs_cm.tags.multi_add(resource_hrefs:[@@array.href], tags:["array:scale_state=scaled_up"])
    # Else scale down if scale_state != scaled_down
    elsif (!($minute >= 30 && $minute <= 45) && ($scale_state != "scaled_down"))
        # Do the scale_down operation
        call scale_down($params)
        # Add tag to change the scaled_state
        rs_cm.tags.multi_add(resource_hrefs:[@@array.href], tags:["array:scale_state=scaled_down"])
    end
end
