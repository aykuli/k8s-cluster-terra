# Диплом Айнур Шауэрман в профессии DEVOPS

## Содержание

* [1. [Cloud.ru] Создание облачной инфраструктуры](#1-cloudru-создание-облачной-инфраструктуры)

  * [1.1 Настройка нового провайдера облака](#11-настройка-нового-провайдера-облака)
  * [1.2 Terraform проект для сервисных аккаунтов, container registry и бакета](#12-terraform-проект-для-сервисных-аккаунтов-container-registry-и-бакета)

* [2. Приложение simple-app](#2-приложение-simple-app)
* [3. Создание виртуальных машин для кластера](#3-создание-виртуальных-машин-для-кластера)
* [4. `Ansible` проект работы с виртуальными машинами](#4-ansible-проект-работы-с-виртуальными-машинами)
* [5 K8s проект, манифесты, kubectl get entities](#5-k8s-проект-манифесты-kubectl-get-entities)
* [6. Итоговое задеплоенное приложение](#6-итоговое-задеплоенное-приложение)
* [7. Размышления дальше](#7-размышления-дальше)

---------------
* [Исторические записи до 7 октября с работой в Яндекс Облаке](#исторические-записи-до-7-октября)

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

![](./assets/44.png)

## 1.2 Terraform проект для сервисных аккаунтов, container registry и бакета

Проект под Cloud.ru находится папке [cloudru-sa-regstor](./cloudru-sa-regstor/), где провайдер:

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


Container Registry всё никак не созадвался. Создала из ЛК и испортировала в терраформ
![](./assets/32.png)


В итоге создала:
*  сервисные аккаунты для работы 

  * в проекте `diploma-sa`
  * в вм-ах получать изображения приложения `vm-sa`
  * в репозиторий для пуша в container registry `ci-cd-sa`

Ключи и секреты надо сохранить, но они, в принципе, если не менять `terraform`, всегда доступны через `terraform output`.

`Container Registry`, который в `Cloud.ru` называется `Artifact Registry`:

![](./assets/45.png)
![](./assets/46.png)
![](./assets/47.png)

**Создание бакета**

![](./assets/30.png)


![](./assets/60.png)



## 2. Приложение simple-app

Репозиторий:

* [https://github.com/aykuli/simple-app](https://github.com/aykuli/simple-app)

Ключи доступа сервисного аккаунта ci-cd-sa сохранила в секретах репозитория:

![](./assets/48.png)

Файл пайплайна `ci-cd` для `github actions`:

![ci-cd github workflow file](https://github.com/aykuli/simple-app/blob/master/.github/workflows/deploy.yml)


Задеплоила в `container registry cloud.ru`
![](./assets/50.png)


Созданный пайплайном артефакт теперь лежит в хранилище образов:

![](./assets/49.png)


# 3. Создание виртуальных машин для кластера

Находится в папке [cloudru-k8s-cluster/](./cloudru-k8s-cluster/)

Ключи доступа сервисного аккаунта diploma-sa сохраняла в перменных окружения, указанных ниже:

```shell
$ terraform init \
  -backend-config="access_key=$ACCESS_KEY" \
  -backend-config="secret_key=$SECRET_KEY"
```
![](./assets/13.png)

**vpc**

![](./assets/51.png)

![](./assets/52.png)

**subnets**

![](./assets/53.png)

![](./assets/54.png)

![](./assets/55.png)

**Группы безопасности**

![](./assets/56.png)

![](./assets/57.png)

![](./assets/58.png)

**Виртулаьные машины**

![](./assets/59.png)

Их больше, чем в терраформ проекте, т.к. некоторые создала врукопашную, тестировала платформу.
Виртуальные машины, которым по каким-то причинам стало плохо, я выключила нан сейчас.
При создании виртульаных машин автоматичеси создаётся файл `inventory.yml` из шаблона [cloudru-k8s-cluster/templates/inventory.tmpl](./cloudru-k8s-cluster/templates/inventory.tmpl) и кладется в соседнюю папку ansible.

# 4. `Ansible` проект работы с виртуальными машинами

`Ansible` проект находится в папке [ansible/](./ansible/)
Мастер и воркер роли разделены в ролях, общие части находтся в роди `common`.


![](./assets/33.png)
![](./assets/34.png)
![](./assets/35.png)
![](./assets/43.png)

Запуск иногда проиходил не так, как я ожидала.
Виртуальные машины вели себя странно, то есть доступ, то нет доступа. Только воркер2 оставался стабилно доступным.

# 5 K8s проект, манифесты, kubectl get entities

Kubernetis проект находится в папке [kube](./kube):

| filename | description |
| -------- | ----------- |
| namespace.yml | `aynur` |
| deploy.yml | там используется `imagePullSecrets`, созданный на скрине выше. |
| service.yml | сервис для моего лейбла `aynur: diploma` |
| ingress.yml | необходимый для того, чтобы связать внешний мир с изолированной внутренней сетью вашего кластера Kubernetes. Тут важно помнить, что в группе безопасности я открыла 80 порт для входящих запросов. |
| ingress-rbac-patch.yml |  выдаёт  Ingress-контроллеру права доступа, чтобы он мог легитимно опрашивать кластер Kubernetes и управлять маршрутами. |

Но не все шаги я всё-таки оказывается описала в проекте.

Дополнительно в мастере я создавала секрет для доступа в закрытый `Artefacts Repository` `cloud.ru`:

![](./assets/39.png)


На мастере я также спушила текущий репозиторий с помощью `git clone ...`, чтобы скачать манифесты кубернетиса.

![](./assets/61.png)

## 6. Итоговое задеплоенное приложение

![](./assets/62.png)


IP воркера я открыла специально. Хотела увидеть, что работает. Потому что с закрытием ip-шников уже задание было ранее.

## 7 Размышления дальше

Для 5 штук виртульаных машин для Grafana:

| Компонент | Процессор (CPU) | Оперативная память (RAM) | Дисковое пространство (SSD/NVMe) |
| ---- | ---- | ---- | --- |
| Prometheus | 0.5 – 1 ядро | 512 МБ – 1 ГБ | 10 – 30 ГБ |
| Grafana | 0.2 – 0.5 ядра | 256 МБ – 512 МБ | 1 – 2 ГБ (для базы данных sqlite) |
| Итого для VPS / сервера | 1 – 2 ядра | 2 ГБ | 20 – 45 ГБ |

Большую систему мониторинга я разворачивала для [Априорные Решения Машин](https://armmeh.ru/) - здесь лежит [https://github.com/aykuli/armmeh_promgraf_telemetry](https://github.com/aykuli/armmeh_promgraf_telemetry). Потратила на это 3 недели, с меня на этом мониторинга пока хватит.

На следующей неделе буду разворачивать мониторинг на текущей работе, ману поберегу.

Я на этом всё. Спасибо за ваше внимание! Удачи вам и мне на нашем тернистом пути разработки!

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

