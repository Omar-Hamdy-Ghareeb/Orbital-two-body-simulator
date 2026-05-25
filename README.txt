ORBIT SIMULATOR - INSTALLATION AND USAGE GUIDE

00. Before installation, ensure MATLAB R2019b or later is installed. 
    Verify you have at least 4GB of RAM available.

0. Download all .m files to a single directory on your computer.
   Essential files: main.m, get_sat.m, get_orbit_rv.m, tle_to_latlong.m,
   ecef_from_eci.m, Prefocal_to_ECI.m

1. Add the directory containing all .m files to MATLAB path.
   In MATLAB Command Window, type: addpath('C:\path\to\orbit-simulator')
   Replace with your actual directory path.

2. Run the simulator by typing "main" in MATLAB Command Window.
   This will execute using the default Molniya orbit TLE.

3. To use a different satellite, edit main.m file:
   Find the line: filename = mol;
   Replace with one of these options:
   filename = ISS;       % International Space Station
   filename = GPS;       % GPS satellite
   filename = galileo;   % Galileo navigation satellite
   filename = nilesat;   % Communications satellite

4. To customize simulation duration, edit main.m:
   Find the line: t_final = ti + 24*60*60;
   Change "24" to desired number of hours.

5. To adjust time step for accuracy/speed, edit main.m:
   Find the line: dt = 100;
   Lower values (10-50) = more accurate, slower
   Higher values (200-500) = less accurate, faster

6. Using your own TLE file:
   6.1 Create a text file with exactly 3 lines:
       Line 1: Satellite name
       Line 2: TLE line 1 (standard NORAD format)
       Line 3: TLE line 2 (standard NORAD format)

   6.2 Place this file in the simulator directory
   
   6.3 Edit main.m: filename = "yourfile.txt";

   6.4 Run "main" in MATLAB

7. Using position and velocity vectors instead of TLE:
   In MATLAB Command Window, type:
   r0 = [7000; 0; 0];       % Initial position [km]
   v0 = [0; 7.5; 0];        % Initial velocity [km/s]
   t_start = 0;             % Start time [seconds]
   t_end = 86400;           % End time [seconds] (24 hours)
   out = get_orbit_rv(r0, v0, t_start, t_end);

8. The simulator will generate three figures:
   Figure 1: 3D orbit views in ECI, ECEF, and perifocal frames
   Figure 2: Ground track colored by velocity and altitude
   Figure 3: Time plots of altitude, velocity, and true anomaly

9. Blue lines represent calculated orbits
   Green dots (if visible) represent MATLAB Aerospace Toolbox comparison
   Red marker = starting point
   Green marker = ending point
   Yellow marker = perigee (closest point to Earth)

10. If you encounter "Undefined function" errors:
    Ensure all .m files are in the same directory
    Verify the directory is in MATLAB path
    Try: addpath(genpath('C:\path\to\orbit-simulator'))

11. If MATLAB Aerospace Toolbox is not installed:
    The simulator will work normally
    Only "Earth Reference" and "Satellite Orbit" will appear in ground track plots
    No comparison with MATLAB Toolbox will be shown

12. For slow performance:
    Increase dt value in main.m (e.g., dt = 300;)
    Reduce simulation duration (e.g., 1 hour instead of 24)
    Close other MATLAB figures and applications

13. To stop the simulation, close all figure windows or press Ctrl+C in Command Window.

14. Simulation complete when all three figures are displayed.
    No further action required.

================