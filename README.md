# Dual-Port RAM: Design & Verification (SV env & UVM env)

A compact **dual-port RAM** in SystemVerilog with two verification flows  
**1)** a lightweight class-based SV testbench (generator, driver, monitor, scoreboard, coverage)  
**2)** a reusable **UVM** environment for constrained-random, coverage-driven closure

I built two environments to understand which features are necessary in **UVM** versus **plain SV**, and where each approach is the better fit for efficiency, reuse, and coverage closure.

> **Read-during-write policy**  
> Default **READ_FIRST** — when `wr_en` and `rd_en` are high on the same cycle and `wr_addr == rd_addr`, the read port returns the **old** data while the write updates memory for the next cycle.

---

##  Repository Structure

~~~text
rtl/
  dp_ram_design.sv            // Parameterizable true dual-port RAM (WIDTH, DEPTH)

tb_sv/                        // SV testbench
  if/intf.sv
  gen/generator.sv
  drv/driver.sv
  mon/monitor.sv
  sb/scoreboard.sv
  cov/cov.sv
  testbench.sv               // -> TB Top 

uvm/                          // UVM environment
  pkg/dpr_uvm_pkg.sv          // includes all UVM components
  env/dp_env.sv               //
  agent/               // seq_item, sequencer, driver, monitor
  sequences/seq_base.sv
  sequences/seq_write.sv
  sequences/seq_read.sv
  sequences/seq_mixed.sv
  sequences/seq_raw_next_cycle.sv
  test/dp_test.sv
  testbench.sv               // -> TB Top
~~~

---

##  Design Highlights

* Dual-port RAM with independent address, data, and enables per port  
* Parameterizable data width and depth  
* Simple, explicit **collision policy** parameter (READ_FIRST)  
* Clean package centralizes typedefs and policy selection

---

##  Why add UVM alongside SV

* Constrained-random across two ports to reach rare collision corners  
* Coverage-driven closure with targeted crosses (addr × op × collision)  
* Reusable agents and sequences for memory-like IPs  
* Clear separation of stimulus, checking, and coverage  

### Where the SV bench helps

* Fast bring-up and smoke tests  
* Minimal code for quick waveform debug  
* Deterministic directed scenarios

---

##  Functional Coverage (UVM + SV)

* Address bins for min, max, middle, wraparound  
* Operation types per port (read, write)  
* Collision matrix for same-address and different-address activity  
* Timing gaps between ports (aligned, small offset, back-to-back)  

---

##  Scoreboard and Checks

* Cycle-aware reference model that honors selected collision policy  
* Immediate and concurrent assertions for protocol sanity  
* Data consistency checks across both ports and cycles

---

##  Current Status

* SV bench used for fast sanity and directed checks  
* UVM bench used for regressions and coverage closure  
* Collision scenarios and read-during-write behavior verified against policy

---

##  Next Steps

* Add optional byte-enable support in RTL and coverage  
* Negative testing and error-injection sequences  
* Export merged coverage summary to docs/results

---

## 📄 License

MIT (or update to your chosen license)

---

## 📬 Contact

Kartik Verma  
Open an issue on GitHub or reach out on LinkedIn(www.linkedin.com/in/vkartik07)
