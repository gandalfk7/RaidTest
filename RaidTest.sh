#! /bin/sh

#variables
FILE="/storage/MD0/autotest.img" #test file location on a mountpoint
MD_DEV="md0"                           #raid device to test
FILESIZE=8192                           #filesize of testfile in MB
BLOCKSIZE="1M"                          #blocksize for dd
var_date=$(date +"%Y.%m.%d_%H%M%S")

#save variables:
ori_readahead=$(cat /sys/class/block/$MD_DEV/queue/read_ahead_kb)
ori_stripecache=$(cat /sys/block/$MD_DEV/md/stripe_cache_size)
echo "ReadAhead:        $ori_readahead" > settings_ori_$var_date
echo "StripeCache:      $ori_stripecache" >> settings_ori_$var_date

#heading of the chart
echo "ReadAh    Stripe  WRITE   READ"

for READ_AHEAD in 1024 1536 4096 32768 262144 524288; do
        blockdev --setra $READ_AHEAD /dev/$MD_DEV
        for STRIPE_CACHE_SIZE in 256 512 1024 2048 4096 8192 16384 32768; do
                echo ${STRIPE_CACHE_SIZE} > /sys/block/$MD_DEV/md/stripe_cache_size
                RES_WRITE=`dd if=/dev/zero of=$FILE bs=$BLOCKSIZE count=$FILESIZE conv=fdatasync  2>&1 | awk '/bytes/{print $(NF-1), $NF}'`
                sync
                RES_READ=`dd if=$FILE of=/dev/null bs=$BLOCKSIZE 2>&1 | awk '/bytes/{print $(NF-1), $NF}'`
                echo 3 > /proc/sys/vm/drop_caches
                echo "$READ_AHEAD       $STRIPE_CACHE_SIZE      $RES_WRITE      $RES_READ"
        rm $FILE
        done
done

echo " "
echo "Setting original value of $ori_readahead to Read Ahead"
blockdev --setra $ori_readahead /dev/$MD_DEV
echo "Setting original value of $ori_stripecache to Stripe Cache Size"
echo $ori_stripecache > /sys/block/$MD_DEV/md/stripe_cache_size
echo " "
echo "Finished"
