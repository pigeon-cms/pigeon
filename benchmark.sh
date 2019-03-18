#!/bin/bash
cd Benchmarking
vegeta attack -rate=60 -duration=6s -timeout=10s -targets=./vegeta.txt | vegeta report
