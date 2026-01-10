# parametric-timer-vhdl
### Parametric timer module in VHDL with VUnit verification.

This project implements a parametrized timer in VHDL, verified using an automated testing environment with VUnit into and integrated into a CI/CD pipeline.

## Local Installation Guide (Windows)
 - Install Python:
 1. Visit [python.org](https://www.python.org/downloads/) and download
 2. Very important to add python.exe to PATH.

- Install GHDL:
1. Download the **mcode** zip file for Windows from the [GHDL Releases](https://github.com/ghdl/ghdl/releases)
2. Extract folder to a safe location (e.g. `C:\GHDL`)
3. Edit the system environment variables by clicking the **Environment Variables** button, then adding to *Path* the path of the GHDL bin folder (e.g. `C:\GHDL\bin`)
4. Open a new PowerShell and type `ghdl --version`to see the version details

- Install VUnit library by running the following command in the PowerShell:
`pip install "vunit_hdl>=5.0.0.dev3"`

## Project Structure
```plaintext
parametric-timer-vhdl/
├── parametric-timer/
|   ├── src/
|   |   └── timer.vhd
│   ├── test/
|   |   └── tb_timer.vhd
│   └── run.py
├── .gitignore
├── .github/
|   └── worflows/
|       └── ci.yml
└── README.md
```

## Running Test Locally
To execute the test locally:
1. Navigate to the project's folder `parametric-timer`
2. Open a terminal window inside the folder
3. Run the following code: `python run.py -v`


## CI/CD Integration
This repository includes a **GitHub Actions** workflow (`.github\workflows\ci.yml`).
Every time code is pushed:
1. A virtual Linux environment is launched
2. GHDL and VUnit are automatically installed
3. The full test suite is executed.

## Verification Logic
For each parameter set, the testbench performs the following checks:

1. **Reset Behavior**: Ensures the done signal is de-asserted and counters are cleared during a reset.

2. **Timing Accuracy**: Measures the time between the start of the timer and the assertion of the done flag to ensure it matches the expected cycle count.

3. **Continuous Operation**: Verifies that the timer can be restarted immediately after completion.

### How to add a new test case
To test a specific case, add the following line to the `run.py` file:
`tb.add_config(name="X", generics=dict(clk_freq_hz_g=int(Y), delay_ns_g=Z))`

- X: name of the test case
- Y: scientific notation number (e.g. 100e6)
- Z: integer number (e.g. 100), measure in ns