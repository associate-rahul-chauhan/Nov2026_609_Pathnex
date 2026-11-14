======= headless service explanation =======
A headless service in Kubernetes is created by setting the clusterIP field to None.
This allows direct access to the individual pods rather than routing through a load balancer.
It is useful for stateful applications where you need to connect to specific pods.
For example, databases like PostgreSQL or MySQL often use headless services to allow clients to connect to individual database instances directly.

USE CASE: we have 3 mongodb pods and we want that each client can connect to specific pod rather than being load balanced across all pods.

real app example: 
In the headless service YAML file, we have defined a service named my-headless-svc with clusterIP set to None. This allows clients to connect directly to the individual pods selected by the label app: my-db on port 5432.
In this way, each pod can be accessed individually, which is particularly useful for stateful applications like databases where each instance may hold unique data. 
This approach ensures that clients can maintain a stable connection to a specific pod, which is essential for scenarios requiring consistent data access and state management.  

