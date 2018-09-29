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

ip=$(/sbin/ifconfig | grep "inet addr" | sed -n 1p | cut -d':' -f2 | cut -d' ' -f1)


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
plinks="##### 反向代理： [Google](http://$ip:8888/search?q=425事件) - [维基百科](http://$ip:8100/wiki/喬高-麥塔斯調查報告) - [大纪元新闻网](http://$ip:10080) - [新唐人电视台](http://$ip:8000) - [希望之声](http://$ip:8200) - [神韵艺术团](http://$ip:8000/xtr/gb/prog673.html) - [我的博客](http://$ip:10000/)"
vlinks="##### 精彩视频： [《时事小品》](https://github.com/gfw-breaker/ntdtv-comedy/blob/master/README.md) - [《传奇时代》](http://$ip:10000/videos/legend/) - [《风雨天地行》](http://$ip:10000/videos/fytdx/) - [《九评共产党》](http://$ip:10000/videos/jiuping/) - [《漫谈党文化》](http://$ip:10000/videos/mtdwh/) - [709维权律师大抓捕](http://$ip:10000/videos/709/)"
cd /root/wenzhao
git pull
sed -i '5,$d' README.md
cat $md_page >> README.md
sed -i "10 a$vlinks" README.md
sed -i "10 a$plinks" README.md
git commit -a -m 'ok'
git push


