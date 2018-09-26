#!/bin/bash
# author: gfw-breaker

if [ $# -eq 1 ]; then
	video_count=$1
else
	video_count=5
fi

video_dir=/usr/share/nginx/html/wenzhao
index_page=$video_dir/index.html
md_page=$video_dir/index.md
youtube_url=https://www.youtube.com/playlist?list=PL2DywIam67jsFoEhIvVhB0HukSP8IAIt0

ip=$(ifconfig | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)


# download videos
cd $video_dir
youtube-dl -f 18 \
	--max-downloads $video_count \
	-i $youtube_url


# generate page
echo > $md_page
cat > $index_page << EOF
<html>
<head>
<meta charset="utf-8" /> 
</head>
<body>
EOF

for v in $(ls -t *.mp4); do
	title=$(echo $v | cut -d'-' -f1)
	name=$(echo $v | sed "s/'//g")
	echo "<a href='http://$ip/wenzhao/$name'>$title</a></br></br>" >> $index_page
	echo "##### <a href='http://$ip/wenzhao/$name'>$title</a>" >> $md_page
done
echo "</body></html>" >> $index_page


# commit
cd /root/wenzhao
git pull
sed -i '5,$d' README.md
cat $md_page >> README.md
git commit -a -m 'ok'
git push


