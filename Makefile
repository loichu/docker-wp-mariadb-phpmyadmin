#!make

_mysql_group_id_in_docker = 999
_apache_group_id_in_docker = 33

check-env:
ifeq (,$(wildcard wp-docker-stack.env))
	@echo "Please create your .env file first, from .env.sample"
	@exit 1
else
include wp-docker-stack.env
export $(shell sed 's/=.*//' wp-docker-stack.env)
endif

copy-env-sample:
	cp wp-docker-stack.env.sample wp-docker-stack.env

up: check-env
	@DOCKER_CONTAINER_PREFIX=${DOCKER_CONTAINER_PREFIX}
	docker-compose up -d
	@if ! test -w logs; then \
		$(MAKE) perm; \
	fi
	@if ! test -f logs/general.log; then \
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
	@docker-compose logs -f

logs-wp:
	@docker-compose logs -f wordpress

logs-sql:
	@tail -f logs/general.log

logs-debug:
	@tail -f wp/wp-content/debug.log

logs-db:
	@docker-compose logs -f db

logs-errors:
	$(MAKE) logs-wp | grep -E 'error|notice'
