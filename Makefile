#!make

_mysql_group_id_in_docker = 999
_apache_group_id_in_docker = 33

up:
	docker-compose up -d
	if ! test -f logs/general.log; then \
		touch logs/general.log; \
		if ! test -w wp; then \
			$(MAKE) perm; \
		fi \
	fi

perm:
	sudo chmod -R g+w wp logs
	sudo chown -R $(USER):$(_apache_group_id_in_docker) wp
	sudo chown -R $(USER):$(_mysql_group_id_in_docker) logs

down:
	docker-compose down

logs:
	docker-compose logs -f

logs-wp:
	docker-compose logs -f wordpress

logs-sql:
	tail -f logs/general.log

logs-debug:
	tail -f wp/wp-content/debug.log

logs-db:
	docker-compose logs -f db

logs-errors:
	$(MAKE) logs-wp | grep -E 'error|notice'
