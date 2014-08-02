#!/bin/sh
# parametry wywwo³ania zawsze 4 (ver 3.0 ultimate)
# ( katalog ¼ród³owy (/home/gargus), katalog docelowy (/home/gargus/), liczba kopii (5), plik kopii (kopia) )
#
#                               PRZYK£AD
#
#  sh ./backup.sh /usr /root/ 4 usrfile
#  kopiuje katalog usr 
#  kopia bedzie nazywaæ siê /root/usrfile_YYYY_MM_DD___HH.zip 
#  trzymane bêd± 4 ostatnie kopie

logfile='/var/log/backup'                        # plik z logami przebiegu wykonywania kopii
tmpfile='/tmp/delete.sh'                         # plik pomocniczy
kopfile=`date +"$4_"%Y"_"%m"_"%d"___"%H`.tgz.gpg     # nazwa pliku z kopi±
lockfile='/var/run/backup.run'                   # robi siê kopia
header="Raport_wykonania_kopii"                  # naglowek maila z bledami
mailto="root@localhost"                          # mail do uzytkownika
passw="/root/pass4tar"
exlist="/root/exclude.lst"

# dalej nie poprawiaæ

 lerror=1
 nicev=19
 ziplevel=6
echo Rozpoczynam wykonywanie kopii > $logfile

/etc/rc.d/smb stop
/etc/rc.d/nmb stop

if test -f $lockfile; then
  echo '   'Upps kopia sie wlasnie robii ! >> $logfile
else
  if test -s $2$kopfile ; then
	echo '   'juz istnieje kopia nie bede robil ponownej >> $logfile
  else
#	nice -n $nicev tar -cvzf $2$kopfile $1 >> $logfile
	umask 177
        /root/bin/gpgstart.sh
        sleep 1
        nice -n $nicev tar -cpz -X $exlist -C $1 . | gpg --batch --no-tty --passphrase-file $passw --symmetric --cipher-algo AES256 -o $2$kopfile >> $logfile
	if test $? -eq 0; then
		/bin/sync
		/bin/sync
		echo '   'kopia poprawna urrraaaa! >> $logfile
		lerror=0
	else
		echo '   'ups blad pakowania pliku tar zwrocil blad >> $logfile
	fi	
  fi

#  rm -f /backup/na_local/$4_*.*
#  cp -f $2$kopfile /backup/na_local

  # funkcja która usuwa stare pliki kopii

    rm -f $lockfile   >> $logfile
    touch $lockfile   >> $logfile
    rm -f $tmpfile    >> $logfile
    echo '#!/bin/sh'  >> $tmpfile
         k=1
         for I in  `ls -lt --format=single-column $2$4*`; do
		if test $k -le $3 ; then
			echo '   'zostaje $I >> $logfile
		else
		        echo '   'usuwam plik kopii $I >> $logfile
			chmod 777 $I  >> $logfile
			rm -f $I      >> $logfile
		fi
		k=$(expr $k + 1)
	 done

  # pozosta³o tylko tyle kopii ile poda³em jako parametr


  /bin/sync
  if test `ls -lt --format=single-column $2$4* | wc -l` -eq $3 ; then
	echo Ok zostalo tyle kopii ile mialo pozostac >> $logfile
  else
	echo Opps cos jest nie tak sprawdz stan kopii >> $logfile
	lerror=2
  fi
  rm -rf $lockfile
fi

if test $lerror -ne 0; then
	echo 'Blad podczas wykonywania kopii!' >> $logfile
	cat $logfile | mail -s $header $mailto
fi


# kopia na NAS-server
umount /mnt/local
mount -o username=backup-user,password=jikolp //192.168.0.5/backup /mnt/local
cp $2$kopfile /mnt/local
rm -f /mnt/local/back/*.tgz
cp $2$kopfile /mnt/local/back
find /mnt/local/*.tgz -type f -mtime +30 -exec rm -rf {} \;
umount /mnt/local
rm /mnt/local/*

scp -i /root/.ssh/zawad -P 60037 $2$kopfile wiezien@195.43.85.195:/home/wiezien/dezako/

/etc/rc.d/smb start
/etc/rc.d/nmb start

