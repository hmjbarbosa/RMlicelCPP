base=`pwd`

cd data
for arq in `find . -name 'RM*'` ;  do
    dir=`dirname $arq | sed 's#./##' `
    fin=$base/data/$dir/`basename $arq`

    fout=$base/link/$dir/`../rm2name $arq`

    mkdir -p $base/link/$dir
    ln -s $fin $fout
done


#