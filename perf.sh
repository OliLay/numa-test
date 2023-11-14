#!/bin/bash
PID=$(pidof numa-test)
perf stat -e ls_any_fills_from_sys.mem_io_remote,ls_any_fills_from_sys.ext_cache_remote,ls_any_fills_from_sys.mem_io_local,ls_any_fills_from_sys.ext_cache_local,ls_any_fills_from_sys.int_cache,ls_any_fills_from_sys.lcl_l2 --pid ${PID} 
#perf stat -e ls_dmnd_fills_from_sys.mem_io_remote,ls_dmnd_fills_from_sys.ext_cache_remote,ls_dmnd_fills_from_sys.mem_io_local,ls_dmnd_fills_from_sys.ext_cache_local,ls_dmnd_fills_from_sys.int_cache,ls_dmnd_fills_from_sys.lcl_l2 --pid ${PID} 