# Диплом Айнур Шауэрман в профессии DEVOPS

## 1. Создание облачной инфраструктуры

### 1.1. Создание первичных необходимых сущностей

Для S3-бэкенда Terraform нужен 
  
  * статический ключ доступа (access key + secret key) сервисного аккаунта.
  * созданное хранилище

Создание этих первичных сущностей находит в папке [init-service-account-registry-storage/](./init-service-account-registry-storage/)

Создаются:

1) Сервисные аккаунты

  * [diploma-sa](./init-s3-service-account-and-registry/1_service-account.tf#L2) с правами, котрые понадобятся в дальнейшем для обслуживания инфрастуктуры
    
    с ключами для работы с backend S3 bucket:
      * [static-key](./init-s3-service-account-and-registry/1_service-account.tf#L23)


  * [github-action-sa](./init-s3-service-account-and-registry/3_container-registry.tf#L6)
    c правами пушить изоражения с `github actions` и затем пользоваться в Кубере:

      * [container-registry.admin](./init-s3-service-account-and-registry/3_container-registry.tf#L13)
    с ключами, котрые я скопировала в `github action secrets` для автоматического деплоя:
      * [service_account_key](./init-s3-service-account-and-registry/3_container-registry.tf#L19)
      *

Запустила `terraform apply`:

![](./assets/1.png)

Тут необходимо скопировать созданные секреты. Сделала командами:

```shell
$ terraform output -json github_actions_secrets > github_actions_secrets.json
$ terraform output -raw s3_access_key > s3_access_key.txt
$ terraform output -raw s3_secret_key > s3_secret_key.txt

$ export YC_BUCKET_ACCESS_KEY="<access_key>"
$ export YC_BUCKET_SECRET_KEY="<secret_key>"
```

### 1.2. Создание инфрастукртуры для мастер и воркер нод Кубернетиса

```
[localhost] ──kubectl──► [Мастер API: публичный IP :443/:6443]
                              │
                              ▼ (внутренняя сеть VPC)
                        [Воркер-1] [Воркер-2] [Воркер-3]
                              │
                              └──► интернет (тянуть образы)
```

Инфраструктра создаётся через терраформ, описанный в [infra-terra/](./infra-terra/)

```shell
$ cd infra-terra
$ terraform init \
  -backend-config="access_key=$YC_BUCKET_ACCESS_KEY" \
  -backend-config="secret_key=$YC_BUCKET_SECRET_KEY"
```

## 2. Создание Kubernetes кластера

## 3. Создание тестового приложения


Скопировала полученные данные в репозиторий приложения:

* [https://github.com/aykuli/simple-app](https://github.com/aykuli/simple-app)

    * Для доступа к хранилищу Яндекса используется [yc-actions/yc-cr-login](https://github.com/yc-actions/yc-cr-login#usage)



3) Создала приложение и экшн к нему

4) Задеплоила в `container registry YC`

5) Результат создания Хранилища и Сохраения в Хранилище Образ приложения ниже:

![](./assets/2.png)
![](./assets/3.png)
![](./assets/4.png)
![](./assets/5.png)
![](./assets/6.png)
![](./assets/7.png)
