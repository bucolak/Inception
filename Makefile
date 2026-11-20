DATA_DIR = /home/bucolak/data
COMPOSE  = docker compose -f srcs/docker-compose.yml

all: up

up:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v --rmi all

fclean: clean
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all up down clean fclean re