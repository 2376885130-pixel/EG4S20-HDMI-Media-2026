# Hardware Bring-up Checklist

## Current Status

Official lab_ex_4: NOT IMPORTED

Official lab_ex_5: NOT IMPORTED

Board Verification: NOT STARTED

---

# Phase 1 — lab_ex_4

## Project

[ ] Official lab_ex_4 imported without modification

[ ] TD project opens successfully

[ ] Device / package configuration confirmed

[ ] Constraints loaded

[ ] PLL configuration confirmed

[ ] Synthesis passes

[ ] Place & Route passes

[ ] Timing report generated

[ ] Programming file generated

---

## Board

[ ] HX4S20C powers normally

[ ] FPGA programming succeeds

[ ] 50 MHz board clock works

[ ] Reset works

---

## TF / BMP

[ ] TF card recognized

[ ] Expected BMP files found

[ ] BMP image loads

[ ] 640x480 image displays correctly

[ ] RGB colors correct

[ ] No obvious image corruption

---

## SDRAM

[ ] Frame write succeeds

[ ] Frame read succeeds

[ ] No obvious FIFO overflow

[ ] No obvious FIFO underflow

[ ] Double buffer behavior observed

---

## HDMI

[ ] Monitor detects HDMI signal

[ ] Resolution / timing accepted

[ ] Stable image displayed

[ ] No obvious tearing

[ ] No periodic corruption

---

## Control

[ ] Manual image switching works

[ ] Automatic slideshow works

[ ] Repeated switching remains stable

---

## Stability

[ ] Reset recovery works

[ ] Multiple image cycles work

[ ] Cold boot tested

[ ] Extended runtime tested

---

# Phase 2 — lab_ex_5

[ ] lab_ex_5 imported without modification

[ ] All video baseline tests still pass

[ ] 48 kHz audio path works

[ ] HDMI audio detected

[ ] Test tone audible

[ ] Audio and video operate simultaneously

[ ] Reset recovery works

[ ] Cold boot tested

[ ] Extended runtime tested

---

# Golden Reference Rule

A Git tag containing:

board-verified

may only be created after actual hardware verification.

Compilation alone is not sufficient.

Simulation alone is not sufficient.
