# RaidTest
Bash script to find the best combination of ReadAhead and stripe_cache_size in a RAID5 array

the output will look something like:
```
ReadAh  Stripe	WRITE	READ
1536  512	97.3 MB/s	1.6 GB/s
1536  1024	132 MB/s	1.5 GB/s
1536  2048	166 MB/s	1.5 GB/s
1536  4096	205 MB/s	1.7 GB/s
```
