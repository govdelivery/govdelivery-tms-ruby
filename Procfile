oracle: cd $ORACLEVM_HOME && vagrant up
redis: redis-server $REDIS_CONFIG
web:    bundle exec trinidad start -p `expr $PORT - 200`
ngrok:  ngrok -log stdout -authtoken $NGROK_TOKEN -subdomain $NGROK_SUBDOMAIN `expr $PORT - 300`
worker: bundle exec sidekiq


