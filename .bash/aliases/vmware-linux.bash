#alias linux='{ ssh -o ConnectTimeout=1 linux; } || { echo "Linux not running. Starting..."; /cygdrive/c/Program\ Files\ \(x86\)/VMware/VMware\ Workstation/vmrun.exe -T ws start "V:\VMware\Linux\Linux.vmx";  ssh linux; }'
alias linux='ssh -Y -o ConnectTimeout=1 linux; (( $? == 255 )) && { /cygdrive/c/Program\ Files\ \(x86\)/VMware/VMware\ Workstation/vmrun.exe -T ws start "D:\VMware\Linux\Linux.vmx";  ssh linux; }'
