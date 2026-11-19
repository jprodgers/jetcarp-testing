# Not counted: the suite and parity at 7:32–7:44 AM EST ran with no GPU

Jimmie switched to F-2's test account at about 7:33 (fast user switching). logind then took the GPU away from the
background session these ran in (`/dev/dri/card1`'s ACL changed at 07:33), and wgpu found no adapter. So:
- parity ran on the processor only ("adapter: none", "all 300 generations on the GPU in 0"): these files;
- the suite on the tag had one failure, `status_follows_the_gpu_setting`, whose no-GPU branch doesn't hold with
  `JETCARP_GPU` unset: #138 (0.4.3, test only).

Both run again with Jimmie's session in front.
