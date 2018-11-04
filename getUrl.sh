#! /bin/bash

function insertSort(){
    ARRAY=( $(echo $1) );

    LENGTH=$(( ${#ARRAY[*]} ))
    for (( i=1; i<LENGTH; i++ ))
    do
        PIVOT=${ARRAY[${i}]};
        j=$((i-1));
        while [ ${j} -ge 0 ] && [ ${ARRAY[${j}]} -gt ${PIVOT} ]
        do
            ARRAY[$((j+1))]=${ARRAY[${j}]};
            ((j--));
        done
        ARRAY[${j}+1]=${PIVOT};
    done

    echo "${ARRAY[*]}"
}

function sortByDate() {
    FILE_PATH_ARRAY=( $(echo $1) );
    i=0;
    declare -A FILE_MAP
    for FILE_PATH in ${FILE_PATH_ARRAY[*]}
    do
        TEMP_FILE_PATH=${FILE_PATH#*/public/}
        YEAR_MON_DAY=( $(echo ${TEMP_FILE_PATH} | awk 'BEGIN{FS="/"} {print $1 " " $2 " " $3}') );
        TIME_ORDER=$(( 10#${YEAR_MON_DAY[0]} * 10000 + 10#${YEAR_MON_DAY[1]} * 100 + 10#${YEAR_MON_DAY[2]} ));
        TIME_ORDER_ARRAY[${i}]=${TIME_ORDER};
        FILE_MAP["${TIME_ORDER}"]=${FILE_PATH};
        ((i++));
    done

    # 排序
    TIME_ORDER_ARRAY=( $(insertSort "${TIME_ORDER_ARRAY[*]}") )

    i=0;
    for TIME_ORDER in ${TIME_ORDER_ARRAY[*]}
    do
        FILE_PATH_ARRAY[${i}]=${FILE_MAP["${TIME_ORDER}"]};
        ((i++))
    done

    echo "${FILE_PATH_ARRAY[*]}"
}

DIR=$1;

# 除去 从右往左 第一个/以及右边所有字符。例如a/b/c/ -> a/b/c
DIR=${DIR%/*};

if [ ! -d ${DIR}/public ]
then
    echo "Wrong dir: $DIR";
    exit 1;
fi

# 博客地址前缀
BLOG_URL_PREFIX=https://liuyehcf.github.io/;

# 年份
YEARS=(2017 2018);

# 查找所有index.html文件，一个文件对应一篇博文

INDEX_FILES="";

for YEAR in ${YEARS[*]}
do
    INDEX_FILES="${INDEX_FILES} $(find ${DIR}/public/$YEAR -name 'index.html')";
done

# 文章的总数
COUNT=$(echo ${INDEX_FILES} | awk '{print NF}');

# 每一个文章的路径
FILE_PATH_ARRAY=( $(echo ${INDEX_FILES}) );

# 按照日期排序
FILE_PATH_ARRAY=( $(sortByDate "${FILE_PATH_ARRAY[*]}") )

rm -f ${DIR}/url.list;

for FILE_PATH in ${FILE_PATH_ARRAY[*]}
do
    # 此时FILE_PATH形如:`public/2018/01/12/Mac-个性化配置/index.html`

    # 除去public/
    FILE_PATH=${FILE_PATH#*public/};

    # 除去最右边的/index.xml
    FILE_PATH=${FILE_PATH%/index.html}"/";

    # 合成最终的访问url
    URL=${BLOG_URL_PREFIX}${FILE_PATH};

    echo $URL >> ${DIR}/url.list;
done