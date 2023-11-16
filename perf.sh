#!/bin/bash

set -o nounset -o errexit # -o xtrace

EVENTS=(
  "ls_dmnd_fills_from_sys.mem_io_remote"
  "ls_dmnd_fills_from_sys.ext_cache_remote"
  "ls_dmnd_fills_from_sys.mem_io_local"
  "ls_dmnd_fills_from_sys.ext_cache_local"
  "ls_dmnd_fills_from_sys.int_cache"
  "ls_dmnd_fills_from_sys.lcl_l2"

  "ls_sw_pf_dc_fills.mem_io_remote"
  "ls_sw_pf_dc_fills.ext_cache_remote"
  "ls_sw_pf_dc_fills.mem_io_local"
  "ls_sw_pf_dc_fills.ext_cache_local"
  "ls_sw_pf_dc_fills.int_cache"
  "ls_sw_pf_dc_fills.lcl_l2"

  "ls_hw_pf_dc_fills.mem_io_remote"
  "ls_hw_pf_dc_fills.ext_cache_remote"
  "ls_hw_pf_dc_fills.mem_io_local"
  "ls_hw_pf_dc_fills.ext_cache_local"
  "ls_hw_pf_dc_fills.int_cache"
  "ls_hw_pf_dc_fills.lcl_l2"

  "ls_any_fills_from_sys.mem_io_remote"
  "ls_any_fills_from_sys.ext_cache_remote"
  "ls_any_fills_from_sys.mem_io_local"
  "ls_any_fills_from_sys.ext_cache_local"
  "ls_any_fills_from_sys.int_cache"
  "ls_any_fills_from_sys.lcl_l2"
)

events_to_args() {
  local IFS="$1"
  shift
  echo "$*"
}

CMD="./build/numatest"
PERF_ARGS="$(events_to_args , ${EVENTS[*]:18:4})"
#PERF_ARGS="$(events_to_args , ${EVENTS[*]:18})"
#PERF_ARGS="$(events_to_args , ${EVENTS[*]:0:1}),$(events_to_args , ${EVENTS[*]:6:1}),$(events_to_args , ${EVENTS[*]:12:1}),$(events_to_args , ${EVENTS[*]:18:1})"

echo "$PERF_ARGS"

FIFO=/tmp/.numa_test_fifo

if [ -p $FIFO ]; then
  echo "Warning: FIFO queue still exists (remove manually 'rm -f $FIFO'')"
  exit 0
fi

PROMPT="Please attach with perf and then hit some key"
mkfifo $FIFO

cat $FIFO | $CMD ${*} | while read -r LINE; do
  echo $LINE
  if [[ "$LINE" =~ ^"${PROMPT}".* ]]; then
    PID=$(pidof numatest)

    numastat -c $PID # print NUMA alloc stats
    perf stat -e $PERF_ARGS --pid $PID &
    sleep 0.5
    echo "" > $FIFO
  fi
done

PERF_PID=$(pidof perf)
while [ -e /proc/$PERF_PID ]; do sleep 1; done
rm -f $FIFO

