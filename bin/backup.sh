#!/bin/sh
#  sh ./backup.sh /usr /root/ 4 usrfile
#  kopiuje katalog usr
#  kopia bedzie nazywac sie /root/usrfile_YYYY_MM_DD___HH.zip
#  trzymane beda 4 ostatnie kopie

logfile='/var/log/backup'                        # plik z logami przebiegu wykonywania kopii
tmpfile='/tmp/delete.sh'                         # plik pomocniczy
kopfile=`date +"$4_"%Y"_"%m"_"%d"___"%H`.tgz     # nazwa pliku z kopia
lockfile='/var/run/backup.run'                   # robi sie kopia
header="Raport_wykonania_kopii"                  # naglowek maila z bledami
mailto="root@localhost"                          # mail do uzytkownika

#dalej nie poprawiac

 lerror=1
 nicev=19
 ziplevel=6
echo Rozpoczynam wykonywanie kopii > $logfile

if test -f $lockfile; then
  echo '   'Upps kopia sie wlasnie robii ! >> $logfile
else
  if test -s $2$kopfile ; then
        echo '   'juz istnieje kopia nie bede robil ponownej >> $logfile
  else
        nice -n $nicev tar -cpzf $2$kopfile $1 >> $logfile
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


  # funkcja ktora usuwa stare pliki kopii

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

  # pozostalo tylko tyle kopii ile podalem jako parametr


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

eval $(ssh-agent)
ssh-add /root/.ssh/ocean

rsync -azhe "ssh -p 56789" $2$kopfile bubblocean@poseidon:/home/bubblocean/Back/

ssh-add -D

pid=`pgrep -u root "ssh-agent"`

if [ $pid -eq "0" ]
    then
        echo "agent is not running"
    else
        kill $pid
    echo "agent  stopped"
fi