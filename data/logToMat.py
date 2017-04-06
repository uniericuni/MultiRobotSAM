import scipy.io as sio
import os, sys, re

def main():

    # iterate over all files
    for log_file in os.listdir('.'):
    
        # regular expression matching
        full_file_name = log_file.split('.')
        file_name = full_file_name[0]+'.mat'
        format = full_file_name[1]
        if format != "log":
            continue

        # write data into .mat
        mat = {}
        f = open(log_file, 'r+')
        for line in f:
            readLine(mat, line)
        sorted(mat['pose'], key=lambda x:x['time'])
        sorted(mat['laser'], key=lambda x:x['time'])
        sio.savemat(file_name, mat)

        # close file
        print '%s saved'%file_name
        f.close();

# read line into .mat
def readLine(mat, line):

    # parse data in fields
    fields = line.split()
    [ server_time, robot_name, port, sensor_type, sensor_id, data_time ] = fields[:6]
    data = fields[6:]
   
    # initiate data
    if 'name' not in mat:
        mat['name'] = robot_name
        mat['pose'] = []
        mat['laser'] = []

    # write control feedback data
    if sensor_type == "position":
        pose = {'time':float(data_time)}
        assert len(data)==6
        pose['x'] = float(data[0])
        pose['y'] = float(data[1])
        pose['theta'] = float(data[2])
        pose['vel_x'] = float(data[3])
        pose['vel_y'] = float(data[4])
        pose['vel_theta'] = float(data[5])
        mat['pose'].append(pose)

    # write sensor data
    if sensor_type == "laser":
        laser = {'time':float(data_time), 'range':[], 'bearing':[], 'intensity':[]}
        for i,val in enumerate(data):
            if i%3==0:
                laser['range'].append(float(val))
            elif i%3==1:
                laser['bearing'].append(float(val))
            else:
                laser['intensity'].append(float(val))
        mat['laser'].append(laser)

if __name__ == '__main__':

    main()
