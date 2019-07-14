# Docker Glassfish 3.1.2

**Example docker-compose.yml**

```yml
version: '3'
services:
   glassfish:
      image: zx30/glassfish3
      ports:
         - 4848:4848
         - 8080:8080
         - 8181:8181
      environment:
         GLASSFISH_PASSWORD: <password>
      volumes:
         - ./logs:/opt/glassfish3/glassfish/domains/domain1/logs
         - ./config:/gf_config
         - ./deploy:/gf_deploy
```

**First run:**
1. `/gf_config/*.sh` -> `exec`
2. `/gf_config/.jvm-options` -> `asadmin create-jvm-options`
3. `/gf_config/*.xml` -> `asadmin add-resources`
4. `/gf_deploy/*.war` -> `asamin deploy`
5. `/gf_deploy/*.ear` -> `asamin deploy`
6. Start glassfish server