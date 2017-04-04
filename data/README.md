## Data Parser

We provide a data parser in python script for you to generate a structured .mat file rather than pure text. Please frst download and unpack the log file from [this link](http://cres.usc.edu/radishrepository/view-one.php?name=ap_hill_07b) then type

```
$ python logToMat.py
```

in your terminal to parse all the log files in current directory. It is a multi-robot mapping dataset provided by [Radish](http://radish.sourceforge.net/index.php). The parser requires scipy installed.

## Data Structure

If you follow the above instruction, the .mat file should be formed as the following structure.

- name: robot_name
- pose: (cell) list of poses information
    - time: time_stamp
    - x: x coordinate pose value
    - y: y coordinate pose value
    - theta: rotation coordinate pose value
    - vel_x: x coordinate velocity value
    - vel_y: y coordinate velocity value
    - vel_theta: theta coordinate velocity value
- laser: (cell) list of laser information
    - time: time_stamp
    - range: list of obervation range values
    - bearing: list of obervation bearing values
    - intensity: list of obervation intensity values

Notice that elements having the same index in range/bearing/intensity represent the same sensor reponse.
