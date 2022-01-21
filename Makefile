
IMAGE = igrishaev/kafka:latest

docker-build:
	docker build --no-cache -t ${IMAGE} -f latest .

docker-run:
	docker run -it --rm -p 2181:2181 -p 9092:9092 -p 8083:8083 --env-file ENV ${IMAGE}
