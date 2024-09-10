SEARCH_STRING=user:my-user@my-domain.com

ADD_STRING=user:other-user@.my-domain.com

# insert ADD_STRING right after line with SEARCH_STRING for the file named main.tf

sed -i "/$SEARCH_STRING/a $ADD_STRING" main.tf