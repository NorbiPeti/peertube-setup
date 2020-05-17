#!/bin/bash
set -e

echo -e "This will send an email to all users, based on the template in $(pwd)/email-template.txt. Content:\n\n"
cat email-template.txt
echo -e "\n\n"

read -p "Send test email (y/N)? " SEND_EMAIL
case "$SEND_EMAIL" in
  [yY]* ) ;;
  [nN]* ) exit;;
  * ) exit;;
esac

EMAIL_LIST=$(mktemp)
echo $EMAIL_LIST
docker-compose exec -T -u postgres postgres psql -U peertube -d peertube -c "SELECT email FROM public.user WHERE NOT blocked" -t > $EMAIL_LIST
echo "Sending email to $(wc -l $EMAIL_LIST | cut -d' ' -f1) users"

cat $EMAIL_LIST | while read EMAIL
do
    echo "sending to $EMAIL"
    cat email-template.txt | \
        docker exec -i "$(docker-compose ps -q postfix)" sendmail -t "$EMAIL"
done

rm $EMAIL_LIST
