vsim +access+r;
run -all;
acdb save -o fcover.acdb;
acdb report -db  fcover.acdb -txt -o cov.txt -verbose 
exec cat cov.txt;
exit