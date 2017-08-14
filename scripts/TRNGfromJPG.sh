# DESCRIPTION
# Produce true random data (.dat) file all .jpg files in the directory you run this from. reference: https://crypto.stackexchange.com/a/43121

# USAGE
# thisScript.sh input.jpg

# DEPENDENCIES
# xxd. On Cygwin install it via `apt-cyg install hxd`

# TO DO:
# use all non-cryptographic hash functions
# concat hex to binary via dd if possible

rehash -none -fnv64 -md2 -md4 -md5 -sha1 -out:raw -out:pad:false -out:nospaces *.jpg > rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt
# because that results in windows "newlines" (\n\r), change them to 'nix:
dos2unix rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt
# strip down that output to only hex prints and newlines:
sed -i -e 's/.*: \(.*\).*/\1/g' -e 's/<.*>//g' rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt
tr -d '\n' < rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt > no_newlines_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt
timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
xxd -r -p no_newlines_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt __trueRandomData_"$timestamp".dat
rm rnd_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt no_newlines_H3pDjjUNgmbsYjGfaYrKQk6mz8yZHNKSqx.txt

# rehash -out:text -out:pad:false -out:word:512 -out:nospaces 

# DEV NOTES
# usage of rehash:
# rehash [options1] filespec [options2] [> outputfile]
# for further help, see: http://rehash.sourceforge.net/rehash.html#resamples

# usage of xhd to convert a hex string to a binary file (of corresponding actual hex binary values):
# https://stackoverflow.com/a/7826789/1397555 -- e.g. `xxd -r -p in.txt out.bin` OR `echo 17F6EC7100437960F8EEDFD0A2D33B514DCC9726 | xxd -r > out.dat`