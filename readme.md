# Диплом Айнур Шауэрман в профессии DEVOPS

## Содержание

* [1. [Cloud.ru] Создание облачной инфраструктуры](#1-cloudru-создание-облачной-инфраструктуры)

* [Исторические записи до 7 октября](#исторические-записи-до-7-октября)

  * [1. Создание облачной инфраструктуры](#1-создание-облачной-инфраструктуры)

    * [1.1. Создание первичных необходимых сущностей](#11-создание-первичных-необходимых-сущностей)
    * [1.2. Создание инфрастукртуры для мастер и воркер нод Кубернетиса](#12-создание-инфрастукртуры-для-мастер-и-воркер-нод-кубернетиса)

  * [2. Создание Kubernetes кластера](#2-создание-kubernetes-кластера)
  * [3. Создание тестового приложения](#3-создание-тестового-приложения)


## 1. [Cloud.ru] Создание облачной инфраструктуры

### 1.1 Настройка нового провайдера облака

Уносим в сторону Яндекс Провайдера.

```bash
$ cp  ~/.terraformrc ~/.terraformrc-yandex
```

И записваем нового провайдера от Сбера:

```hcl
provider_installation {
   network_mirror {
      url = "https://evo-tf-provider-generic.ar.cloud.ru/"
      include = ["cloudru/*"]
   }
   direct {
      exclude = ["cloudru/*"]
   }
}
```

Проект под Cloud.ru находитсч папке [cloudru-sa-regstor](./cloudru-sa-regstor/), где провайдер:

```hcl
terraform {
  required_providers {
    cloudru = {
      source  = "cloudru/cloud"
      version = "2.1.4"
    }
  }
  required_version = ">= 1.3.0"
}
```

и уже можно инициилизировать проект:

![](./assets/31.png)

## 1.1 [Cloud.ru] Создание бакета

![](./assets/30.png)

Container Registry всё никак не созадвался. Создала из ЛК и испортировала в терраформ
![](./assets/32.png)


## Исторические записи до 7 октября
## 1. Создание облачной инфраструктуры

### 1.1. Создание первичных необходимых сущностей

Создание этих первичных сущностей находит в папке [init-service-account-registry-storage/](./init-service-account-registry-storage/)

Создаются:

1) Сервисные аккаунты для 

  * [diploma-sa](./init-service-account-registry-storage/1_service-account.tf#L2) с правами, котрые понадобятся в дальнейшем для обслуживания инфрастуктуры
    
    с ключами для работы с backend S3 bucket:
      * [static-key](./init-service-account-registry-storage/1_service-account.tf#L30)
      * [diploma_sa_key](./init-service-account-registry-storage/1_service-account.tf#L55)


  * [registry_sa](./init-service-account-registry-storage/3_container-registry.tf#L6)
    c правами пушить изображения с поомщью ci/cd в container registry YC  и затем пулить докер изображения в Кубере:

      * [container-registry.admin](./init-service-account-registry-storage/3_container-registry.tf#L13)
    
    с ключами для автоматического деплоя:
      * [registry_sa_key](./init-service-account-registry-storage/3_container-registry.tf#L19)
      

Запустила `terraform apply`:

![](./assets/0.png)

Тут необходимо скопировать созданные секреты. Сделала командами (с некоторыми запинками, что обычно думаю не только для меня):

```shell
$ terraform output -json registry_secrets > registy_sa_auth_key.json
$ export YC_BUCKET_SECRET_KEY=$(terraform output -no-color -raw s3_secret_key)
$ export YC_BUCKET_ACCESS_KEY=$(terraform output -no-color -raw s3_access_key)
$ source ~/.bashrc
```

Затем добавляю создание `auth_key.json` для сервисного акааунта `diploma-sa`, ведь это нужно для создания виртуальных машин.

![](./assets/6.png)

Этот ключ скопирую в папку с проектом создания виртуальных машин для Кубернетис кластера.

Смотрю результаты.

* Аккаунты для работы:

![](./assets/1.png)
![](./assets/7.png)
![](./assets/10.png)

* Реестр (пока пустой):

![](./assets/4.png)
![](./assets/11.png)

* Хранилище (пока пустой):

![](./assets/5.png)

### 1.2. Создание инфрастукртуры для мастер и воркер нод Кубернетиса


```
[localhost] ──kubectl──► [Мастер API: публичный IP :443/:6443]
                              │
                              ▼ (внутренняя сеть VPC)
                        [Воркер-1] [Воркер-2] [Воркер-3]
                              │
                              └──► интернет (тянуть образы)
```

Создаю профиль, который соотвествует сервисному аккунту `diploma-sa`[1]

![](./assets/12.png)

Инфраструктра создаётся через терраформ, описанный в [infra-terra/](./infra-terra/)

```shell
$ cd infra-terra
$ terraform init \
  -backend-config="access_key=$YC_BUCKET_ACCESS_KEY" \
  -backend-config="secret_key=$YC_BUCKET_SECRET_KEY"
```
![](./assets/13.png)

![](./assets/16.png)

После запуска, получаю 4 ВМ - 1 с названием мастер, 3 - с названием воркеры.
Сущности для кластера создались:


![](./assets/14.png)

Состояние проекта сохранено в ранее созданном бакете.

![](./assets/15.png)


## 2. Создание Kubernetes кластера

В отличие от Yandex Managed Kubernetes, здесь нет автоматической подстановки IAM-токена в поды — её нужно делать вручную через imagePullSecrets.

## 3. Создание тестового приложения


Скопировала полученные данные в `github_actions_secrets.json` и ID container registry в репозиторий приложения:

![](./assets/3.png)

* [https://github.com/aykuli/simple-app](https://github.com/aykuli/simple-app)

    * Для доступа к хранилищу Яндекса используется [yc-actions/yc-cr-login](https://github.com/yc-actions/yc-cr-login#usage)



3) Создала приложение и экшн к нему [deploy.yml](https://github.com/aykuli/simple-app/blob/master/.github/workflows/deploy.yml)

4) Задеплоила в `container registry YC`
![](./assets/2.png)

5) Результат создания Хранилища и Сохраения в Хранилище Образ приложения ниже:

![](./assets/4.png)
![](./assets/5.png)
![](./assets/6.png)
![](./assets/7.png)


## Список литературы

1. [Создание профиля сервисного аккаунта](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage#create-service-account)

