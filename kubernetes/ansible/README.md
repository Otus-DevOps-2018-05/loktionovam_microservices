Quick start
===========

```bash
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
export GCE_REGION=$(gcloud config get-value compute/region 2> /dev/null)
export GCE_CREDENTIALS_FILE_PATH=~/.ansible/gce-service-account.json
export GCE_EMAIL=user@docker-1234.iam.gserviceaccount.com
export GCE_PROJECT=docker-1234

ansible-playbook -K kubernetes_the_hard_way.yml
```
