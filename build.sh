test -r out || mkdir out
ruby zad1.rb > zad1.txt
ruby zad2.rb > zad2.txt
ruby zad3.rb > zad3.txt
ruby zad4.rb > zad4.txt
ruby zad5.rb > zad5.txt
ruby zadII.rb > zadII.txt
mv *.png out/
mv *.txt out/
convert out/zad* raport.pdf
