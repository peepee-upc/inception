all:
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans

clean: down
	docker system prune -a -f

fclean: clean
	sudo rm -rf /home/$(USER)/data/* /home/$(USER)/mysql/*

re: fclean all

