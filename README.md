# ProFuzzPeach - A Toolkit for Protocol Fuzzing with Peach and Peach

# Folder Structure
```
profuzzpeach
├── subjects: contains folders for different protocol implementations
│   └── FTP
│       └── lightftp
│           └── Dockerfile: for building the Docker image specific to the target server
│           └── run.sh: main script to run the experiment inside a Docker container
│           └── other necessary files (e.g., patches, scripts)
└── scripts: contains all scripts for running experiments and analyzing results
    ├── execution
    │   └── profuzzpeach_exec_common.sh: main script to run fuzzing experiments
    └── analysis
        └── profuzzbench_plot.py: sample script for plotting the results
└── README.md: this file
```

# Tutorial - Fuzzing LightFTP server with Peach and Peach*
## Step-0. Set up environmental variables
```
git clone https://github.com/csu-wingmate/profuzzpeach.git
cd profuzzpeach
export PFBENCH=$(pwd)
export PATH=$PATH:$PFBENCH/scripts/execution:$PFBENCH/scripts/analysis
```

## Step-1. Build a Fuzzer Docker image and a Protocol Docker image
```bash
cd $PFBENCH
cd fuzzers/Peach
docker build . -t peach
```
```bash
cd $PFBENCH
cd subjects/FTP/lightftp
docker build . -t lightftp
```

## Step-2. Run fuzzing
- ***1st argument (PROTOCOL)*** : name of the protocol Implementation
- ***2nd argument (RUNS)***     : number of runs, one isolated Docker container is spawned for each run
- ***3rd argument (SAVETO)***   : path to a folder keeping the results
- ***4th argument (FUZZER)***   : fuzzer name (e.g., aflnet) -- this name must match the name of the fuzzer folder inside the Docker container (e.g., /home/ubuntu/aflnet)
- ***5th argument (TIMEOUT)***  : time for fuzzing in seconds
The following commands run 4 instances of Peach and 4 instances of Peach* to simultaneously fuzz LightFTP for 5 minutes.

```bash
cd $PFBENCH
mkdir results-lightftp

profuzzpeach_exec_common.sh lightftp 4 results-lightftp peach 300 &
profuzzpeach_exec_common.sh lightftp 4 results-lightftp peachstar 300
```

A successful script execution will produce output similar to this:
```
Peach: Fuzzing in progress ...
Peach: Waiting for the following containers to stop:  f2da4b72b002 b7421386b288 cebbbc741f93 5c54104ddb86
Peach: I am done!
```

## Step-3. Collect the results
All results are stored in tar files within the folder created in Step-2 (results-lightftp). This includes directories named similarly to peach-1-branch and peach-1-logs, where peach-1-branch contains the collected branch coverage data and peach-1-logs contains the log files from the Peach testing process, including the number of test runs and potential bug reports.

## Step-4. Analyze the results
The branch coverage data collected in Step 3 can be used for plotting. We provide a sample Python script profuzzbench_plot.py to visualize code coverage over time. Use the following command to plot the results and save them to a file.
```bash
cd $PFBENCH/results-lightftp

profuzzbench_plot.py -i <input_data> -o <output_plot_file>
```
Replace <input_data> with the path to your coverage data and <output_plot_file> with the desired filename for your plot.

# Utility Scripts
ProFuzzPeach includes scripts for building and running all fuzzers on all targets with pre-configured parameters. To build all targets for all fuzzers, run the script profuzzpeach_build_all.sh. To execute the fuzzers, use the script profuzzpeach_exec_all.sh.

# FAQs
## 1. How do I extend ProFuzzPeach?
To add a new protocol and/or a new target server for a supported protocol, follow the folder structure outlined above and complete the following steps, using LightFTP as an example:

### Step-1. Create a new folder for the protocol/target server
The folder for LightFTP server is located at subjects/FTP/LightFTP.

### Step-2. Write a Dockerfile and prepare subject-specific scripts/files
Refer to the existing folder structure for LightFTP
