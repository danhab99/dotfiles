function backup() {
  set +x


  tar -cvf - \
    --exclude='**/node_modules' \
    --exclude='**/*cache*' \
    --exclude='**/*Cache*' \
    --exclude='**/.local' \
    --exclude='**/.var' \
    --exclude='**/.var' \
    --exclude='**/.npm' \
    --exclude='**/.go/src' \
    --exclude='**/.go/pkg' \
    --exclude='**/.wine' \
    --exclude='**/.next' \
    /etc /home /usr /srv /opt \
    | pbzip2 -c | gpg --encrypt --recipient FD5C790A4D8633BFC6C5BB592EDED2F32A287529 > backup.tar.bz2.gpg

  split -b 10G --additional-suffix=.tar.bz2.gpg.chunk backup.tar.bz2.gpg backup_chunks/

  date_today=$(date +'%Y-%m-%d')
  s3_folder_path="s3://danhabot-desktop-backups/$date_today/"

  s3cmd put --recursive --acl-private backup_chunks "$s3_folder_path"
}

cd /tmp && backup
