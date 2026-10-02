# Assignment 5 evidence directory

Complete the files in this directory. Do not rename files or create new
evidence files unless the assignment explicitly requires a generated file.

## Evidence collector

Run `./a5-collect-evidence.sh QN <client-internal-ip>` on the gateway after
completing each of Q2, Q3, Q4, Q5, Q6, and Q7 (see the assignment text for
details). Each run writes `qN/evidence.txt`, which is a **required
submission file** for those six questions alongside the corresponding
`qN/answers.md`. It does not replace anything you fill in by hand -- both
are graded.

Q1 is answered entirely by hand (no evidence file). Q7's evidence must be
collected only *after* rebooting both VMs, since the whole point of that
question is to demonstrate the configuration survives a reboot.

## Before submission

Check every file for:

- remaining `WRITE YOUR ANSWER HERE` markers;
- missing command output;
- missing test results;
- incomplete tables;
- a `qN/evidence.txt` file for each of Q2, Q3, Q4, Q5, Q6, Q7.

To submit, create a zip of this directory with

$ cd /home/tsam; zip -r tsam-a5.zip assignment5/

Then submit tsam-a5.zip to Gradescope.
