#!/bin/bash
cd Benchmarking
vegeta attack -rate=100 -duration=14s -timeout=10s -targets=./vegeta.txt | vegeta report
