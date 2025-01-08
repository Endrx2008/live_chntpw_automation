#!/bin/bash
# Smonta tutto
unmount_off() {
  for part in $partitions; do
    mount_point="/mnt/windows/$(basename $part)"
    clear
    sudo umount "$mount_point" && echo "smontate tutte le partizioni"
    sudo rm -rf "$mount_point" && echo "cartella di montaggio eliminata"
  done
}

# stacca stacca (spegne)
poweroff() {
  echo "tutte le operazioni completate"
  read -p "arrivederci..."
  sudo poweroff
}

# Trova le partizioni NTFS
partitions=$(lsblk -o NAME,FSTYPE | grep -i ntfs | awk '{print "/dev/"$1}' | sed 's/[^a-zA-Z0-9\/\-]//g')

# Controlla se ci sono partizioni NTFS
if [ -z "$partitions" ]; then
  echo "Nessuna partizione NTFS trovata."
  exit 1
fi

# Crea la directory di mount
sudo mkdir -p /mnt/windows

# Monta le partizioni NTFS
for part in $partitions; do
  mount_point="/mnt/windows/$(basename $part)"
  sudo mkdir -p "$mount_point"
  sudo mount -t ntfs-3g "$part" "$mount_point" && echo "Partizione $part montata in $mount_point" || echo "Errore durante la montatura di $part"
done

clear
echo "Tutto il necessario è stato montato."

# Elenco delle cartelle montate
folders=$(ls -d /mnt/windows/*/)

# Selezione della partizione
echo "Seleziona una partizione:"
select folder in $folders
do
  if [ -n "$folder" ]; then
    clear
    echo "Hai selezionato: $folder"
    break
  else
    echo "Selezione non valida, riprova."
  fi
done

# Elenco degli utenti nel file SAM
sudo chntpw -l "$folder/Windows/System32/config/SAM" > users_list.txt


# Controlla se ci sono utenti trovati
if [[ ! -s users_list.txt ]]; then
  echo "Nessun utente trovato nel file SAM."
  sudo rm users_list.txt
  unmount_off
  poweroff
fi

# Mostra gli account trovati e memorizza i nomi
counter=1
declare -A users
while read -r line; do
  RID=$(echo "$line" | awk '{print $1}')
  USERNAME=$(echo "$line" | awk '{print $2}')
  users["$counter"]="$USERNAME"
  echo "$counter) $USERNAME (RID: $RID)"
  ((counter++))
done < users_list.txt
sudo rm users_list.txt

# Chiede all'utente di selezionare un account
read -p "Seleziona un account inserendo il numero corrispondente (se da errore premi invio): " choice
if [[ -z "${users[$choice]}" ]]; then
  echo "Selezione non valida."
  unmount_off
  poweroff
fi

# Ottieni il nome utente selezionato
selected_user="${users[$choice]}"
echo "Hai selezionato l'utente: $selected_user"
sam_file="$folder/Windows/System32/config/SAM"

# Esegui chntpw per l'utente selezionato
sudo chntpw -u "$selected_user" "$sam_file"

unmount_off
poweroff
