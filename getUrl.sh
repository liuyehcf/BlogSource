#! /bin/bash

DIR=$1

# 除去 从右往左 第一个/以及右边所有字符。例如a/b/c/ -> a/b/c
DIR=${DIR%/*}

if [ ! -d ${DIR}/public ]
then
    echo "Wrong dir: $DIR"
    exit 1
fi

# 博客地址前缀
BLOG_URL_PREFIX=https://liuyehcf.github.io/;

# 年份
YEARS=(2017 2018);

# 查找所有index.html文件，一个文件对应一篇博文

INDEX_FILES="";

for YEAR in ${YEARS[@]}
do
    INDEX_FILES="${INDEX_FILES} $(find ${DIR}/public/$YEAR -name 'index.html')";
done

# 文章的总数
COUNT=$(echo ${INDEX_FILES} | awk '{print NF}')

# 每一个文章的路径
FILE_PATH_ARRAY=( $(echo ${INDEX_FILES}) )

rm -f ${DIR}/url.list

for FILE_PATH in ${FILE_PATH_ARRAY[@]}
do
    # 此时FILE_PATH形如:`public/2018/01/12/Mac-个性化配置/index.html`

    # 除去public/
    FILE_PATH=${FILE_PATH#*public/}

    # 除去最右边的/index.xml
    FILE_PATH=${FILE_PATH%/index.html}"/"

    # 合成最终的访问url
    URL=${BLOG_URL_PREFIX}${FILE_PATH}

    echo $URL >> ${DIR}/url.list
done
