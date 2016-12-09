#!/bin/bash

cd "`dirname \"$0\"`"

if [ "$1" == "-d" ]
then
  debug=true
else
  debug=false
fi

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

echo "Folge den Anweisungen auf"
echo "  https://wiki.ubuntuusers.de/Systeminformationen_ermitteln/"
echo

echo "(1) PC-Informationen"
sudo dmidecode -t0 -t1 > "01_pc_informationen.out"


echo "(2) Hardware"
echo "(2) Hardware > Allgemeine Informationen"
lspci > "02_hardware_allgemeine_informationen.out"
lspci -vvv > "02_hardware_allgemeine_informationen_ausfuehrlich.out"
echo "(2) Hardware > Ausführliche Hardwareinformationen"
sudo lshw -html > "02_hardware_ausfuehrliche_informationen.html.out"
sudo lshw -short > "02_hardware_ausfuehrliche_informationen.out"
echo "(2) Hardware > hwinfo"
hwinfo > "02_hardware_hwinfo.out"


echo "(3) Motherboard"
echo "(3) Motherboard > Herstellerangaben"
sudo lshw | grep -A6 Motherboard > "03_motherboard_hersteller_und_modell_1.out"
sudo lshw -C system | grep -A6 Motherboard > "03_motherboard_hersteller_und_modell_2.out"
echo "(3) Motherboard > Eigenschaften DMI-Typ 0"
sudo dmidecode -t0 > "03_motherboard_eigenschaften_dmi_typ_0.out"
sudo dmidecode -t0 | grep -Ei "(BIOS boot|EFI)" > "03_motherboard_eigenschaften_uefi.out"


echo "(4) BIOS Version"
sudo dmidecode | grep -A3 'BIOS Information' > "04_bios_version.out"


echo "(5) Prozessor"
echo "(5) Prozessor > Anzeige von Bezeichnung, Hersteller und Taktrate"
sudo lshw -C cpu > "05_prozessor_bezeichnung_hersteller_taktrate.out"
echo "(5) Prozessor > cpuinfo"
cat /proc/cpuinfo > "05_prozessor_cpuinfo.out"
echo "(5) Prozessor > 64-Bit-fähig"
lscpu | grep op-mode > "05_prozessor_64bit.out"
echo "(5) Prozessor > cpuinfo"
cat /proc/cpuinfo > "05_prozessor_cpuinfo.out"


echo "(6) Speicher"
echo "(6) Speicher > Gesamt-, belegter und freier Speicher in MiB"
free -m > "06_speicher_gesamt.out"
echo "(6) Speicher > Detailliert"
sudo lshw -C memory > "06_speicher_detailliert.out"
echo "(6) Speicher > dmidecode"
sudo dmidecode -t memory > "06_speicher_dmidecode.out"


echo "(7) Steckkarten und PCMCIA"
pccardctl info > "07_steckkarten_und_pcmcia.out"


echo "(8) Soundkarten"
echo "(8) Soundkarten > Erkannte Soundkarten"
lspci -nnk | grep -i audio -A2 > "08_soundkarten_erkannte_soundkarten.out"
echo "(8) Soundkarten > ALSA Soundkarten"
cat /proc/asound/cards > "08_soundkarten_alsa_soundkarten.out"


echo "(9) Grafikkarten"
echo "(9) Grafikkarten > Erkannte Grafikkarten"
lspci -nnk | grep -i VGA -A2 > "09_grafikkarten_erkannte_grafikkarten.out"
echo "(9) Grafikkarten > Treiberversion"
glxinfo | grep 'OpenGL version string' > "09_grafikkarten_treiberversion.out"
echo "(9) Grafikkarten > Grafikmodus"
xrandr > "09_grafikkarten_grafikmodus"


echo "(10) Netzwerk"
echo "(10) Netzwerk > Nameserver"
cat /etc/resolv.conf > "10_netzwerk_nameserver.out"
echo "(10) Netzwerk > Netzwerkhardware"
lspci -nnk | grep -i net -A2 > "10_netzwerk_netzwerkhardware.out"
echo "(10) Netzwerk > Schnittstellenkonfiguration"
ifconfig > "10_netzwerk_schnittstellenkonfiguration.out"


echo "(11) WLAN"
echo "(11) WLAN > Schnittstellenkonfiguration"
iwconfig > "11_wlan_schnittstellenkonfiguration.out"


echo "(12) USB"
echo "(12) USB > Alle USB-Geräte"
lsusb > "12_usb_alle_usb_geraete_lsusb.out"
usb-devices > "12_usb_alle_usb_geraete_usb_devices.out"
echo "(12) USB > detailliert"
lsusb -vvv > "12_usb_alle_usb_geraete_detailliert.out"


echo "(13) Optische Laufwerke"
sudo wodim -prcap > "13_optische_laufwerke.out"


echo "(14) Festplatten"
echo "(14) Festplatten > angeschlossene Festplatten"
sed -ne 's/.*\([sh]d[a-zA-Z]\+$\)/\/dev\/\1/p' /proc/partitions > "14_festplatten_angeschlossene_festplatten_ohne_partitionen.out"
sed -ne 's/.*\([sh]d[a-zA-Z]\+[0-9]\+$\)/\/dev\/\1/p' /proc/partitions > "14_festplatten_angeschlossene_festplatten_nur_partitionen.out"
echo "(14) Festplatten > Bezeichnung, Dateisystemtyp, Label, Einhängepunkt, UUID"
sudo blkid -o list -w /dev/null > "14_festplatten_bezeichnung_dateisystemtyp_label_einhaengepunkt_uuid_1.out"
sudo lsblk -o NAME,UUID,FSTYPE,SIZE,LABEL,MOUNTPOINT > "14_festplatten_bezeichnung_dateisystemtyp_label_einhaengepunkt_uuid_2.out"
echo "(14) Festplatten > fdisk"
sudo fdisk -l > "14_festplatten_fdisk.out"
echo "(14) Festplatten > smartctl"
touch "14_festplatten_smartctl.out"
for i in /dev/sd*
do
  sudo smartctl -a "$i" >> "14_festplatten_smartctl.out"
done


echo "Beschreibe Besonderheiten"
beschreibung=beschreibung.out
(
  echo "Typ: "
  echo "Prozessor: "
  echo
) > "$beschreibung"
if [ "debug" == "false" ]
then
  nano "$beschreibung"
fi

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
