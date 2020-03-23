#!/bin/bash 

# Created on 2020-03-22
# @Author: Chau Pham 
# Comment: Automate the project

# Scrape courses from coursera - using default url  
scrapy crawl courses

# Scrape courses from a custom page in Coursera (uncomment and change address to use)
#scrapy crawl courses -a address=https://www.coursera.org/courses

# run RShiny app 
FILES=`ls measurement_results/*json|grep -v hop1`
for file in $FILES
do
    if [[ -s $file ]]; then
        echo "Processing $file"
        JSON=`basename $file`
        Rscript --quiet --no-save --vanilla changepoint.R $JSON
        ROUT="${file}_cp.txt"
        BSOUT="measurement_results/`basename $file .json`_cpbs.out"
        python3 cp_bootstrap.py $file $BSOUT
        IMG1=`basename $file .json`_rchg
        IMG2=`basename $file .json`_bschg
        echo "Making ts images"
        python3 tsplot.py $file $ROUT $IMG1
        python3 tsplot.py $file $BSOUT $IMG2
    fi
done
python3 plotcdf.py