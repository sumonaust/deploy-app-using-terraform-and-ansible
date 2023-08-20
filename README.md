# Deploy Chat Application on Kubernetes Cluster using Terraform, AWS, and Ansible

This repository contains instructions and code to deploy a chat application on a Kubernetes cluster using Terraform to create servers on AWS and configure them via Ansible.

## Prerequisites

Before you begin, you need to have the following:

- An AWS account
- A basic understanding of Terraform, Ansible, Kubernetes and Docker

## Steps

1. Clone the repository

    ```
    git clone https://github.com/rhoumajeder/Deploy_Chat_App
    ```

2. Create a Key on AWS

    Follow the AWS documentation to create a key pair.

3. Initialize Terraform

    ```
    terraform init
    ```

4. Validate the Terraform configuration

    ```
    terraform validate
    ```

5. Plan the Terraform configuration

    ```
    terraform plan
    ```

6. Apply the Terraform configuration

    ```
    terraform apply
    ```

7. Set the permissions for the private key

    ```
    chmod 400 RjeKeys.pem
    ```

8. Connect to the master node

    ```
    Master_Node_ip
    sudo ssh -i "RjeKeys.pem" ubuntu@<master_node_ip>
    ```

9. Connect to the worker nodes

    ```
    Worker_Node1_ip
    sudo ssh -i "RjeKeys.pem" ubuntu@<worker_node1_ip>

    Woker_Node2_ip
    sudo ssh -i "RjeKeys.pem" ubuntu@<worker_node2_ip>
    ```

10. Modify the Ansible host file

    Update the `inventory/vm-setup-playbook/hosts` file with the IP addresses of the Kubernetes cluster nodes.

11. Install Ansible

    ```
    sudo apt install ansible -y
    ```

12. Run the Ansible playbook

    ```
    ansible-playbook --inventory inventory/vm-setup-playbook/hosts vm-setup-playbook.yml
    ```

13. Set the Kubernetes config file permissions

    ```
    sudo chown -R $(whoami) $HOME/.kube
    ```

14. Get the Kubernetes nodes, pods, and services

    ```
    sudo kubectl get nodes -o wide && sudo kubectl get pods && sudo kubectl get services
    ```

15. Create and execute the join command

    ```
    sudo kubeadm token create --print-join-command
    ```

16. Access the chat application via the public IP

    ```
    sudo rsync -avz -e "ssh -i RjeKeys.pem" ../flaskapp ubuntu@<public_ip>:/home/ubuntu
    python app.py
    ```

    That's it! You now have a chat application running on a Kubernetes cluster using Terraform, AWS, and Ansible.

17. Deploy Rocket Chat application

    ```
    sudo rsync -avz -e "ssh -i RjeKeys.pem" ../rocketChatKubernetes ubuntu@3.8.187.241:/home/ubuntu
    kubectl kustomize . | kubectl apply -f -
    kubectl -n rocket-chat get pods
    sudo kubectl -n rocket-chat get nodes -o wide && sudo kubectl -n rocket-chat get services
    ```

18. Access the chat application via the public IP and the port

19. Link with a domain name (optional)

Here are the steps to update the configuration file for `jedder.net` domain, enable HTTPS using certbot, and access Kubernetes dashboard:

20. Open the Nginx configuration file

    ```
    sudo nano /etc/nginx/sites-available/jedder.net
    ```

21. Update the configuration file with the following content:

    ```
    server {
        listen 80;
        server_name 3.8.187.241 jedder.net www.jedder.net;

        location / {
            proxy_pass http://localhost:31321;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location /test {
            proxy_pass http://localhost:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }

    #listen 443 ssl; # managed by Certbot
    #   ssl_certificate /etc/letsencrypt/live/jedder.net/fullchain.pem; # managed by Certbot
    #   ssl_certificate_key /etc/letsencrypt/live/jedder.net/privkey.pem; # managed by Certbot
    #   include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    #   ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    ```

22. Create a symbolic link to enable the site

    ```
    sudo ln -s /etc/nginx/sites-available/jedder.net /etc/nginx/sites-enabled/
    ```

23. Check Nginx configuration

    ```
    sudo nginx -t
    ```

24. Reload Nginx configuration

    ```
    sudo systemctl reload nginx
    ```

25. Obtain SSL certificate using Certbot

    ```
    sudo certbot --nginx -d jedder.net -d www.jedder.net
    ```

26. Open the Nginx configuration file again

    ```
    sudo nano /etc/nginx/sites-available/jedder.net
    ```

27. Remove the default configuration

    ```
    sudo rm /etc/nginx/sites-enabled/default
    ```

28. Restart Nginx

    ```
    sudo systemctl restart nginx
    sudo systemctl reload nginx
    ```

29. Enable Kubernetes dashboard

    ```
    sudo bash enable_kubernetes_dashboard.sh
    ```

30. Start the proxy and open the necessary ports

31. Modify the Nginx configuration file again

    ```
    sudo nano /etc/nginx/sites-available/jedder.net
    ```

32. Add the following content to the configuration file:

    ```
    location /dash {
        proxy_pass http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/;
        # Fix for the subpath issue
        proxy_set_header X-Forwarded-Uri /dash;
        rewrite ^/dash/(.*)$ /$1 break;
        #/dash/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
    }
    ```

33. Reload the Nginx configuration

    ```
    sudo systemctl reload nginx
    ```

34. Create a token for Kubernetes dashboard admin user

    ```
    sudo kubectl -n kubernetes-dashboard create token dashboard-adminuser
    ```




