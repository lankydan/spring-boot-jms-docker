## How to run application

- Clone the application
- Build the application with Maven
  ```
  mvn install
  ```
- Then just start the containers
  ```
  docker-compose up
  ```
That's all you need to do
 
To hit the endpoint in the Spring application, send a `POST` request to:
```
localhost:8080/transaction/send
```
With the body:
```json
{
  "from":"you",
  "to":"me",
  "amount":200
}
```