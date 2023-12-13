#!/bin/bash

#当前主机为ubuntu22x64

# 此脚本用法:
{ \
usage_echo_stmt='echo -e "此脚本$0用法:\n【 HdImg_H=20 bash $0 】（指定 磁盘映像文件 磁头数HdImg_H 为 20）； \n【 bash $0 】（  磁头数HdImg_H 默认为 16）. \n  柱面数HdImg_C固定为${HdImg_C}、每磁道扇区数固定为${HdImg_S}. \n备注：【磁盘映像文件 : 柱面数 HdImg_C 、 磁头数 HdImg_H 、 每磁道扇区数 HdImg_S 都只占据一个字节 因此取值范围都是0到255】 \n\n " '
:;} && \

# 常量
{ \
_SectorSize=512 && _Pwr2_10=$((2**10))
:;} && \


#检测当前是否启动了调试 即 'bash -x'
{ { [[ $- == *x* ]] && _en_dbg=true ;} || _en_dbg=false ;} && \
_=$_en_dbg

# 工具函数

hd_img_dir=$(pwd)/hd_img && \

function _hdImg_list_loopX(){
    { { $_en_dbg && set -x ;} || : ;} && \
    sudo losetup   --raw   --associated  $HdImgF
}

function _hdImg_list_loopX_f1(){
    #此函数的输出 要作为变量loopX的值 因此一定不能放开调试 即 不能加 'set -x'
    # set +x && \
    sudo losetup   --raw   --associated  $HdImgF | cut -d: -f1
}

function _hdImg_detach_all_loopX(){
    { { $_en_dbg && set -x ;} || : ;} && \
    sudo losetup   --raw   --associated  $HdImgF | cut -d: -f1  |   xargs -I%  sudo losetup --detach %
}


function _hdImg_umount(){
    { { $_en_dbg && set -x ;} || : ;} && \
    _hdImg_detach_all_loopX  && { { sudo umount $HdImgF ; sudo umount $hd_img_dir ;} || : ;}
}


function _hdImgDir_rm(){
    { { $_en_dbg && set -x ;} || : ;} && \
    rm -frv $hd_img_dir ; mkdir $hd_img_dir
}


function _hdImg_mount(){
    { { $_en_dbg && set -x ;} || : ;} && \

#mount形成链条:  $HdImgF --> /dev/loopX --> $hd_img_dir/
sudo mount --verbose --options loop,offset=$Part1stByteIdx $HdImgF $hd_img_dir && \

#用losetup 找出上一行mount命令形成的链条中的 loopX
loopX=$( _hdImg_list_loopX_f1 ) && \

#断言 必须只有一个 回环设备 指向 $HdImgF
{ { [ "X$loopX" != "X" ] &&  [ $(echo   $loopX | wc -l) == 1 ] ;} || { eval $err_msg_multi_loopX_gen && exit $err_exitCode_multi_loopX  ;} ;} && \

lsblk $loopX 
#  NAME  MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
#  loop1   7:1    0  50M  0 loop $hd_img_dir

}
####


# 加载（依赖、通用变量）（此脚本中的ifelse调试步骤) (关于此脚本中的 【:;}】) (断点1)
{  \

####{此脚本中的ifelse调试步骤:
###{1. 干运行（置空ifelse）以 确定参数行是否都被短路:
#PS4='[${BASH_SOURCE##*/}] [$FUNCNAME] [$LINENO]: '    bash -x   ./bochs2.7boot-grub4dos-linux2.6.27.15.sh   #bash调试执行 且 显示 行号
#使用 ifelse空函数
# function ifelse(){
#     :
# }
#### 1.结束}

###2. 当 确定参数行都被短路 时, 再 使用 真实 ifelse 函数:
#加载 func.sh中的函数 ifelse
source /crk/bochs/bash-simplify/func.sh
### 2.结束}
#### 此脚本中的ifelse调试步骤 结束}


source /crk/bochs/bash-simplify/dir_util.sh

#当前脚本文件名, 此处 CurScriptF=build-linux-2.6.27.15-on-i386_ubuntu14.04.6LTS.sh
#CurScriptF为当前脚本的绝对路径
#若$0以/开头 (即 绝对路径) 返回$0, 否则 $0为 相对路径 返回  pwd/$0
{ { [[ $0 == /* ]] && CurScriptF=$0 ;} ||  CurScriptF=$(pwd)/$0 ;} && \
CurScriptNm=$(basename $CurScriptF) && \
CurScriptDir=$(dirname $CurScriptF) && \
cd $CurScriptDir && \

### { 关于此脚本中的 【:;}】
# bash中关于 {}  , 结尾的}同一行若有命令x 则 形式必须是 x;} 不能是 x}
#  这里 : 是 空命令, 因此 :;} 符合 形式 x;} 
# :;} 实际 可以写为 } , 写为 :;} 是为了更加醒目 的表示 这是本块业务代码的结束点
### 关于此脚本中的 结束 }

# read -p "断点1" && \
:;} && \


#-1. 指定 磁盘几何参数
{   \
#磁盘映像文件 磁头数 HdImg_H ： 外部指定变量HdImg_H的值 或 默认 16
#磁盘映像文件 : 柱面数 HdImg_C 、 磁头数 HdImg_H 、 每磁道扇区数 HdImg_S 都只占据一个字节 因此取值范围都是0到255
HdImg_C=200 && HdImg_H=${HdImg_H:-16} && HdImg_S=32 && \
#显示本命令用法
eval $usage_echo_stmt && \
#计算磁盘映像文件尺寸
_HdImgF_Sz_MB=$(( HdImg_C * HdImg_H * HdImg_S * _SectorSize / ( _Pwr2_10*_Pwr2_10 ) )) && \
#组装磁盘映像文件名
HdImgF="HD${_HdImgF_Sz_MB}MB${HdImg_C}C${HdImg_H}H${HdImg_S}S.img" && \
#显示 磁盘映像文件名
echo "磁盘映像文件【名:${HdImgF}，尺寸:${_HdImgF_Sz_MB}MB】" && \
#提示是否继续
read -p "按回车开始（停止请按Ctrl+C）" 

:;} && \

#0. 安装apt-file命令(非必需步骤)  （断点2）
{   \
echo $CurScriptF $LINENO
# read -p "断点1"
# debug_ifelseif=true
{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  apt-file --help 2>/dev/null 1>/dev/null
    "已安装apt-file(搜索命令对应的.deb安装包)"
    {  which mkdiskimage  1>/dev/null 2>/dev/null || apt-file search mkdiskimage ;}
  #else:
    sudo apt install -y apt-file && sudo apt-file update
      "apt-file(搜索命令对应的.deb安装包)安装完毕"
} \
} && [ $__e == 0 ] && \

# read -p "断点2"
:;} && \

#1. 安装mkdiskimage命令
{  \

function _is_mkdiskimage_installed(){
#测试mkdiskimage 是否存在及正常运行
mkdiskimage  __.img 10 8 32 2>/dev/null 1>/dev/null && _="若 mkdiskimage已经安装," && \
dpkg -S syslinux 2>/dev/null 1>/dev/null  && dpkg -S syslinux-common 2>/dev/null 1>/dev/null && dpkg -S syslinux-efi 2>/dev/null 1>/dev/null    && _="且 syslinux、syslinux-common、syslinux-efi都已经安装,"
}

set msgInstOk="mkdiskimage安装完毕(mkdiskimage由syslinux-util提供, 但是syslinux syslinux-common syslinux-efi都要安装,否则mkdiskimage产生的此 $HdImgF 几何参数不对、且 分区没格式化 )"


{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  _is_mkdiskimage_installed
    "已经安装mkdiskimage"
    rm -fv __.img
  #else:
    sudo apt install -y syslinux syslinux-common syslinux-efi syslinux-utils
      "$msgInstOk"
} \
} && [ $__e == 0 ] && \

:;} && \

#2A. 对 磁盘映像: 卸载、删除、删除挂载目录
_hdImg_list_loopX && \
_hdImg_umount && \
_hdImgDir_rm && \
rm -fv hd.img && \

#2. 制作磁盘映像、注意磁盘几何参数得符合bochs要求、仅1个fat16分区
{  \
#  Part1stByteIdx : Partition First Byte Offset : 分区的第一个字节偏移量 ： 相对于 磁盘映像文件hd.img的开头, hd.img内的唯一的分区的第一个字节偏移量

#Part1stByteIdx : PartitionFirstByteOffset: 分区第一个字节在hd.img磁盘映像文件中的位置
Part1stByteIdx=$(mkdiskimage  -F  -o   $HdImgF $HdImg_C $HdImg_H $HdImg_S) && \
#  当只安装syslinux而没安装syslinux-common syslinux-efi时, mkdiskimage可以制作出磁盘映像文件，但 该 磁盘映像文件  的几何尺寸参数 并不是 给定的  参数 200C 16H 32S
#  所以 应该 同时安装了 syslinux syslinux-common syslinux-efi， "步骤1." 已有这样的检测了
# Part1stByteIdx == $((32*512)) == 16384 == 0X4000 == 32个扇区 == SectsPerTrk个扇区 == 1个Track

set msgErr="mkdiskimage返回的Part1stByteIdx $Part1stByteIdx 不是预期值 $((32*512)), 请人工排查问题, 退出码9" && \
{ \
#测试 mkdiskimage返回的Part1stByteIdx是否为 '预期值 即 $((32*512)) 即 16384', 其中 32 是 HdImg_S
[ $Part1stByteIdx == $((HdImg_S*512)) ] ||  { echo $msgErr && exit 9 ;} \
} && \


:;} && \

#3. 断言 磁盘映像几何参数
{  \
#xxd -seek +0X1C3 -len 3 $HdImgF
#0X1C3:HdImg_H -1 : 0X0F:15:即16H:即16个磁头,  0X1C4: HdImg_S : 0X20:32:即32S:即每磁道有32个扇区, 0X1C3:HdImg_C -1 : 0XC7:199:即200C:即200个柱面

#0f20C7 即  用010editor打开 磁盘映像文件  偏移0X1C3到偏移0X1C3+2 的3个字节
 
function _check_hdimgF_geometry_param_HSC(){
#测试mkdiskimage 是否存在及正常运行
HdImg_C_sub1_hex=$( printf "%02x" $((HdImg_C-1)) ) && \
HdImg_H_hex=$(printf "%02x" $((HdImg_H-1)) ) && \
HdImg_S_hex=$(printf "%02x" $HdImg_S ) && \
_HSC_hex_calc="${HdImg_H_hex}${HdImg_S_hex}${HdImg_C_sub1_hex}" && \
_HSC_hex_xxdRdFromHdImgF="$(xxd -seek +0X1C3 -len 3  -plain  $HdImgF)" && \
test "$_HSC_hex_xxdRdFromHdImgF" == "${_HSC_hex_calc}"
}


{ \
{ ifelse  $CurScriptF $LINENO ; __e=$? ;} || true || { \
  _check_hdimgF_geometry_param_HSC
    "磁盘映像文件几何参数HSC正确,_HSC_hex=${_HSC_hex_calc}"
    :
  #else:
    echo "磁盘映像文件几何参数HSC错误【 错误, _HSC_hex_calc=${_HSC_hex_calc} != _HSC_hex_xxdRdFromHdImgF=${_HSC_hex_xxdRdFromHdImgF} 】，退出码为5" && exit 5
      ""
} \
} && [ $__e == 0 ] && \

#  注意sfdisk显示磁盘的几何参数与diskgenius的不一致,这里认为sfdisk是错误的，而diskgenius是正确的
# sfdisk --show-geometry $HdImgF

#不需要 parted 、 mkfs.vfat 等命令 再格式化分区，因为mkdiskimage制作 磁盘映像文件时 已经 格式化过分区了

:;} && \
 
#4. 用win10主机上的grubinst.exe安装grldr.mbr到磁盘镜像


# 4.0 必须人工确保win10中的mingw(msys2)中已安装并已启动sshServer



# 4.2 安装sshpass sshfs


# 4.2b 利用sshfs挂载远程sshserver主机根目录


# 4.3 磁盘映像 复制到 win10主机msys2的根目录下


#5A 对 磁盘映像: 新建目录/boot/syslinux/，放置 syslinux.cfg,  安装 syslinux
{   \
# 5A.0 挂载 磁盘映像
_hdImg_mount && \

# 5A.1 syslinux 中指定的 目录 /boot/syslinux/ 必须要事先建立.
sudo mkdir -p  $hd_img_dir/boot/syslinux/ && \

# 5A.2 放置 syslinux.cfg 到 磁盘映像文件
sudo cp syslinux.cfg $hd_img_dir/boot/syslinux/syslinux.cfg  && \

# 5A.3 卸载hd.img后, 再 安装syslinux (  复制 ?mbr?、ldlinux.sys 、ldlinux.c32) 到 磁盘映像hd.img 
_hdImg_umount && \
syslinux --directory /boot/syslinux/ --offset $Part1stByteIdx --install $HdImgF && \

:;} && \


#9. 编译内核 内核编译机器为本机ubuntu22
{  \
bzImageF=/crk/linux-stable/arch/x86/boot/bzImage && ls -lh $bzImageF && \
{ test -f $bzImageF || bash build-linux4.14.259-on-x64_u22.04.3LTS.sh :;} && \
:;} && \


#10A. 挂载 磁盘映像文件
{   \
_hdImg_mount 

:;} && \

#10. 复制 内核bzImage  到 磁盘映像文件
{   \

okMsg1="正常,发现linux内核编译产物:$bzImageF"
errMsg2="错误,内核未编译（没发现内核编译产物:$bzImageF,退出码为8"

{ test -f $bzImageF  && echo $okMsg1 && sudo cp -v $bzImageF  $hd_img_dir; } || { echo $errMsg2  && exit 8 ;  } 

:;} && \

#11. 制作 initrd(即 init_ram_filesystem 即 初始_内存_文件系统)

#11.1 下载busybox-i686
{ \

#initrd: busybox作为 init ram disk
# busybox_i686_url="http://ftp.icm.edu.pl/packages/busybox/binaries/1.16.1/busybox-i686"
busybox_i686_url="https://www.busybox.net/downloads/binaries/1.16.1/busybox-i686" && \
{ test -f busybox-i686 ||  wget --no-verbose $busybox_i686_url ;}
chmod +x busybox-i686

:;} && \

# 11.2 创建 init 脚本
{ \

chmod +x init

:;} && \

#11.3  执行 cpio_gzip 以 生成 initRamFS
{     \

initrdF=$(pwd)/initramfs-busybox-i686.cpio.tar.gz
RT=initramfs && \
(rm -frv $RT &&   mkdir $RT && \
cp busybox-i686 init $RT/ &&  cd $RT  && \
# 创建 initrd
{ find . | cpio --create --format=newc   | gzip -9 > $initrdF ; }  ) && \
:;} && \

#12. 复制 initRamFS 到 磁盘映像文件
{  \
sudo cp $initrdF $hd_img_dir

#todo: 或initrd: helloworld.c作为 init ram disk
#未验证的参考: 
# 1. google搜索"bzImage启动initrd"
# 2. 编译Linux内核在qemu中启动 : https://www.baifachuan.com/posts/211b427f.html

:;} && \

#13. 卸载 磁盘映像文件
{  \
read -p "按回车即将卸载"

_hdImg_umount && \

:;} && \

#14. 生成 bxrc文件（引用 磁盘映像文件）
{  \

sed -e "s/\$HdImgF/$HdImgF/g"  -e "s/_cylinders_/$HdImg_C/g"  -e "s/_heads_/$HdImg_H/g" -e "s/_spt_/$HdImg_S/g" linux-2.6.27.15-grub0.97.bxrc.template > gen-linux-2.6.27.15-grub0.97.bxrc

:;} && \

#15. bochs 执行 bxrc文件( 即 磁盘映像文件 即 grubinst.exe安装产物{grldr.mbr}、grub4dos组件{grldr、menu.lst}、内核bzImage、初始内存文件系统initRamFS{busybox-i686})
{  \
mvFile_AppendCurAbsTime  bochsout.txt && \
# /crk/bochs/linux4-run_at_bochs/bochsout.txt
/crk/bochs/bochs/bochs -f gen-linux-2.6.27.15-grub0.97.bxrc
:;} && \

_=end