# SNMP Polling Tool

The SNMP Polling Tool is a Python script designed to monitor SNMP counters and calculate their rate of change over time.

## Table of Contents
- [Introduction](#introduction)
- [Requirements](#requirements)
- [Usage](#usage)
- [Command-line Arguments](#command-line-arguments)
- [Output Format](#output-format)

## Introduction
This tool is used for polling SNMP-enabled devices and collecting counter values for specified OIDs. It calculates the rate of change for each counter and outputs the results to the console.

## Requirements
- Python 3.x
- `easysnmp` library (Install using `pip install easysnmp`)

## Usage
To use the SNMP Polling Tool, run the script from the command line with the following arguments:
- `python snmp_polling_tool.py <hostname>:<community> <polling_interval> <num_samples> <OID1> <OID2> ... <OIDn>`

## Command-line Arguments
- `<hostname>:<community>`: SNMP target in the format `hostname:community`, where `hostname` is the IP address or hostname of the SNMP-enabled device, and `community` is the SNMP community string.
- `<polling_interval>`: Time interval in seconds between consecutive SNMP requests.
- `<num_samples>`: Number of samples to collect. Use `-1` for an infinite number of samples.
- `<OID1> <OID2> ... <OIDn>`: List of SNMP Object Identifiers to poll and calculate rates. 

## Output Format
The tool prints the results to the console in the following format:
- timestamp|rate1|rate2|rate3|...
Where `timestamp` is the UNIX timestamp of the sample, and `rate1`, `rate2`, etc., represent the calculated rates of change for the specified OIDs.

This README provides a brief overview of the SNMP Polling Tool, including its purpose, requirements, usage, and output format. Users can follow the instructions to run the script and collect SNMP counter data effectively.


