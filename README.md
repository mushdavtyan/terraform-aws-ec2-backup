<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://i.imgur.com/6wj0hh6.jpg" alt="Project logo"></a>
</p>

<h3 align="center">Terraform AWS EC2 Backup</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/mushdavtyan/terraform-aws-ec2-backup.svg)](https://github.com/mushdavtyan/terraform-aws-ec2-backup/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/mushdavtyan/terraform-aws-ec2-backup.svg)](https://github.com/mushdavtyan/terraform-aws-ec2-backup/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> This project sets up an EC2 instance on AWS that creates daily backups and sends them to an S3 bucket.
    <br> 
</p>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Prerequisites](#prerequisites)
- [Installing](#installing)
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>

This project automates the deployment of an EC2 instance on AWS, configured to create daily backups and send them to an S3 bucket. 

## 🏁 Getting Started <a name = "getting_started"></a>

These instructions will help you get a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on deploying the project on a live system.

### Prerequisites <a name = "prerequisites"></a>

Before you begin, ensure you have the following prerequisites installed:

- Terraform ~> 1
- AWS CLI ~> 5
- Git

### Installing <a name = "installing"></a>

1. Clone the repository:

2. Rename `env.rc.tmpl` to `.env.rc` and set your environment variables:

```bash
mv env.rc.tmpl .env.rc
```

3. Edit env.rc and set the following variables:

```bash
export AWS_REGION=eu-west-2
export KEY_NAME="fxctest"
export BACKUP_PATH_DIR="/opt"
export S3_BUCKET_NAME="fxc-my-backup-bucket"
```

### Deployment <a name = "deployment"></a>
To deploy the EC2 instance, run the initial_setup.sh script:
```bash
./initial_setup.sh
```
After deployment, you will see the output SSH command to log in to the EC2 instance.

### Usage <a name="usage"></a>
The main initial_setup.sh and teardown.sh scripts can be run (assuming the env.rc file has been properly configured) to create and remove the resources. Before running the scripts, make sure to duplicate the env.rc.tmpl file and rename it to env.rc, then input the necessary values.


### Built Using <a name = "built_using"></a>
-Terraform - Infrastructure as Code

-AWS - Cloud Provider

## ✍  Authors <a name = "authors"></a>
@mushdavtyan - Initial work

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
Hat tip to anyone whose code was used
Inspiration
References

## License
MIT 