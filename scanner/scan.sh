#!/bin/bash

cd "`dirname \"$0\"`"

scanner_id_file="../scanner-id"

if ! [ -f "$scanner_id_file" ]
then
  python3 -c"import random; print(random.randint(0, 1000000))" > "$scanner_id_file"
fi
scanner_id="`cat \"$scanner_id_file\"`"

echo -n "Identifiziere den Computer: "
read id

dir=../hardware/"$id"/scan
mkdir -p "$dir"
cd "$dir"

echo "Lese RAM"

free -m > free-m.out
sudo dmidecode -t memory > dmidecode-memory.out

echo "Lese USB"

lsusb -vvv > lsusb_vvv.out

echo "Lese Netzwerk"

ifconfig > ifconfig.out

echo "Lese Festplatten"
sudo fdisk -l > fdisk-l.out
touch smartctl-a.out
for i in /dev/sd*
do
  sudo smartctl -a "$i" >> smartctl-a.out
done

echo "Lese CPU"
cat /proc/cpuinfo > proc_cpuinfo.out

echo "Lese System"
cat /etc/issue > etc_issue.out
uname -a > uname-a.out
lsb_release -a > lsb_release-a.out

echo "Lese Hardwareinformationen"
hwinfo > hwinfo.out
lspci -vvv > lspci-vvv.out
sudo dmidecode -t0 > dmidecode-t0.out

echo "Beschreibe Besonderheiten"
beschreibung=beschreibung.out
echo "Besonderheiten von $id:" > "$beschreibung"
nano "$beschreibung"

echo "Speichere Kopie"
copy="scanner_$scanner_id"
mkdir -p "$copy"
cp *.out "$copy"

echo "Speichere ins git."

git pull
git add --all .
git commit -m"$id inventarisiert."
git push


echo "Fertig, ausschalten."
