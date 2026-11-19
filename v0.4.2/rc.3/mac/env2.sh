# Phase 2 on the Mac (rc.3): source this. Empty settings and library at the start of M-1 (Phase 1's are in $T/phase1/).
export T="$HOME/jetcarp-rc-042c"
export JETCARP_CONFIG_DIR="$T/config" JETCARP_DATA_DIR="$T/data" JETCARP_OUT="$T/out" JETCARP_RUNTIME_DIR="$T/runtime"
unset JETCARP_GPU WGPU_BACKEND JETCARP_LIBRARY
J="$T/bin/jetcarp"
R=/Users/Jimmie/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac
cd "$T"
