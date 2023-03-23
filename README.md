# Platform Interview

Platform engineers build highly available distributed systems using infrastructure as code. Our take home test is designed to evaluate real world activities that are involved with this role. We recognise that this may not be as mentally challenging and may take longer to implement than some algorithmic tests that are often seen in interview exercises. Our approach however helps ensure that you will be working with a team of engineers with the necessary practical skills for the role (as well as a diverse range of technical wizardry).


## 🧪 Sample application
The sample application consists of four services:

```
┌─────────────┐     ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│             │     │              │    │              │    │              │
│   payment   │     │   account    │    │   gateway    │    │   frontend   │
│             │     │              │    │              │    │              │
└─────────┬───┘     └──────┬───────┘    └──────┬───────┘    └──────────────┘
          │                │                   │
          │                │                   │
          │                ▼                   │
          │         ┌──────────────┐           │
          │         │              │           │
          └────────►│    vault     │◄──────────┘
                    │              │
                    └──────────────┘
```                    

Three of those services connect to [vault](https://www.vaultproject.io/) to retrieve database credentials. The frontend container serves a static file.

The project structure is as follows:

```
.
├── docker-compose.yml
├── README.md
├── run.sh
├── Vagrantfile
├── services
│   ├── account
│   ├── gateway
│   └── payment
└── tf
    └── main.tf
```
1. Refactoring the Terraform code found in the [tf](./tf) directory is the primary focus of this test.
1. `Vagrantfile`, `run.sh` and `docker-compose.yml` are used to bootstrap this sample application; refactoring these files is not part of the test, but these files may be modified if your solution requires it.
1. The `services` code is used to simulate a microservices architecture that connects to vault to retrieve database credentials. The code and method of connecting to vault can be ignored for the purposes of this test.

## Using an M1 Mac?
If you are using an M1 Mac then you need to install some additional tools:
- [Multipass](https://github.com/canonical/multipass/releases) install the latest release for your operating system
- [Multipass provider for vagrant](https://github.com/Fred78290/vagrant-multipass)
    - [Install the plugin](https://github.com/Fred78290/vagrant-multipass#plugin-installation)
    - [Create the multipass vagrant box](https://github.com/Fred78290/vagrant-multipass#create-multipass-fake-box)

## 👟 Running the sample application
- Make sure you have installed the [vagrant prerequisites](https://learn.hashicorp.com/tutorials/vagrant/getting-started-index#prerequisites)
- In a terminal execute `vagrant up`
- Once the vagrant image has started you should see a successful terraform apply:
```
default: vault_audit.audit_dev: Creation complete after 0s [id=file]
    default: vault_generic_endpoint.account_production: Creation complete after 0s [id=auth/userpass/users/account-production]
    default: vault_generic_secret.gateway_development: Creation complete after 0s [id=secret/development/gateway]
    default: vault_generic_endpoint.gateway_production: Creation complete after 0s [id=auth/userpass/users/gateway-production]
    default: vault_generic_endpoint.payment_production: Creation complete after 0s [id=auth/userpass/users/payment-production]
    default: vault_generic_endpoint.gateway_development: Creation complete after 0s [id=auth/userpass/users/gateway-development]
    default: vault_generic_endpoint.account_development: Creation complete after 0s [id=auth/userpass/users/account-development]
    default: vault_generic_endpoint.payment_development: Creation complete after 1s [id=auth/userpass/users/payment-development]
    default: 
    default: Apply complete! Resources: 30 added, 0 changed, 0 destroyed.
    default: 
    default: ~
```
*Verify the services are running*

- `vagrant ssh`
- `docker ps` should show all containers running:

```
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                       NAMES
6662939321b3   nginx:latest                         "/docker-entrypoint.…"   3 seconds ago    Up 2 seconds    0.0.0.0:4080->80/tcp                        frontend_development
b7e1a54799b0   nginx:1.22.0-alpine                  "/docker-entrypoint.…"   5 seconds ago    Up 4 seconds    0.0.0.0:4081->80/tcp                        frontend_production
4a636fcd2380   form3tech-oss/platformtest-payment   "/go/bin/payment"        16 seconds ago   Up 9 seconds                                                payment_development
3f609757e28e   form3tech-oss/platformtest-account   "/go/bin/account"        16 seconds ago   Up 12 seconds                                               account_production
cc7f27197275   form3tech-oss/platformtest-account   "/go/bin/account"        16 seconds ago   Up 10 seconds                                               account_development
caffcaf61970   form3tech-oss/platformtest-payment   "/go/bin/payment"        16 seconds ago   Up 8 seconds                                                payment_production
c4b7132104ff   form3tech-oss/platformtest-gateway   "/go/bin/gateway"        16 seconds ago   Up 13 seconds                                               gateway_development
2766640654f3   form3tech-oss/platformtest-gateway   "/go/bin/gateway"        16 seconds ago   Up 11 seconds                                               gateway_production
96e629f21d56   vault:1.8.3                          "docker-entrypoint.s…"   2 minutes ago    Up 2 minutes    0.0.0.0:8301->8200/tcp, :::8301->8200/tcp   vagrant-vault-production-1
a7c0b089b10c   vault:1.8.3                          "docker-entrypoint.s…"   2 minutes ago    Up 2 minutes    0.0.0.0:8201->8200/tcp, :::8201->8200/tcp   vagrant-vault-development-1
```

## ⚙️ Task
Imagine the following scenario, your company is growing quickly 🚀 and increasing the number services being deployed and configured.
It's been noticed that the code in `tf/main.tf` is not very easy to maintain 😢.

We would like you to complete the following tasks:

- [ ] Improve the Terraform code to make it easier to add/update/remove services
- [ ] Add a new environment called `staging` that runs each microservice
- [ ] Add a README detailing: 
  - [ ] Your design decisions, if you are new to Terraform let us know
  - [ ] How your code would fit into a CI/CD pipeline
  - [ ] Anything beyond the scope of this task that you would consider when running this code in a real production environment


## 📝 Candidate instructions
1. Create a private [GitHub](https://help.github.com/en/articles/create-a-repo) repository containing the content of this repository
2. Complete the [Task](#task) :tada:
3. [Invite](https://help.github.com/en/articles/inviting-collaborators-to-a-personal-repository) me to your private repo
4. Let me know you've completed the exercise


## Submission Guidance

### Shoulds
- Only use plain Terraform in your solution
- Only modify files in the `tf/` directory, `run.sh`, and `docker-compose.yml`
- Keep the current versions of the services running in `development` and `production` environments
- Structure your code in a way that will segregate environments
- 🚨 All environments (including staging) should be created when you run `vagrant up` and the apps should print `service started` and the secret data in their logs 🚨
- Structure your code in a way that allows engineers to run different versions of services in different environments



 - Your design decisions, if you are new to Terraform let us know:

 * There are couple of different ways to improve this script. Workspace have some limitations but it was quick to implement for me due to my busy schedule. I could also do multiple environment setup with terragrunt. 

 
- How your code would fit into a CI/CD pipeline

* It is very easy to integrate my code to CI/CD such as github actions. My strategy would be create separate workflows for each of the environments. For example three different ec2 instances for these environments. Runner will still need to have workspaces but ec2 instance will be running these environments independantly. 

- Anything beyond the scope of this task that you would consider when running this code in a real production environment

* Yes we can do several improvements in this code, specially related to token storage and security. We should use github-secrets, aws secret manager or other tools to secure these tokens and db passwords. We should also setup a backend to store our statefile for example s3 bucket.

