if [ $1 = "start" ] 
then
  echo "Setting work directory to $(pwd)"
  echo "$( pwd )" > /tmp/workdir
fi

if [ $1 = "end" ]
then
  echo "Ending work directory"
  rm /tmp/workdir
fi
