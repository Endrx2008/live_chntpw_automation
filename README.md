# Mount e Gestione Account NTFS con chntpw

Questo script Bash consente di montare automaticamente le partizioni NTFS su un sistema Linux, di elencare gli utenti di Windows contenuti nel file `SAM` e di modificare la password di un account tramite `chntpw`.

## Requisiti

- Un sistema *live* Linux con supporto NTFS (Consigliato Debian).
- I seguenti pacchetti devono essere installati:
  - `ntfs-3g`: per montare le partizioni NTFS.
  - `chntpw`: per interagire con il file `SAM` di Windows ed operarvi sopra.

Per installare questi pacchetti su una distribuzione basata su Debian, esegui il comando:

```bash
sudo apt update
sudo apt install ntfs-3g chntpw
