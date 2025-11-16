# Итоговый проект модуля «Облачная инфраструктура. Terraform»

## ` Дмитрий Климов `

## Задание 1. Развертывание инфраструктуры в Yandex Cloud.

   * Создайте Virtual Private Cloud (VPC).
   * Создайте подсети.
   * Создайте виртуальные машины (VM):
   * Настройте группы безопасности (порты 22, 80, 443).
   * Привяжите группу безопасности к VM.
   * Опишите создание БД MySQL в Yandex Cloud.
   * Опишите создание Container Registry.

## Ответ:

### 1.1. Конфигурация Сети (VPC, Subnet, Security Group)

Вся сетевая инфраструктура описана в файле `network.tf`.

| Компонент | Название / Параметр | Описание |
| :--- | :--- | :--- |
| **VPC** | `final-project-vpc` | Основная сеть проекта. |
| **Subnet** | `final-project-subnet-ru-central1-a` | Подсеть с CIDR `192.168.10.0/24`. |

<img width="1920" height="1080" alt="Снимок экрана (1857)" src="https://github.com/user-attachments/assets/b4965a7f-79d0-4886-9df6-7bcff626cf4e" />

#### Группа Безопасности (`app-security-group`)

SG настроена для обеспечения доступа к VM и внутренней коммуникации:

| Тип | Протокол | Порт | CIDR / Назначение |
| :--- | :--- | :--- | :--- |
| **Ingress** | TCP | 22 | `0.0.0.0/0` | SSH доступ. |
| **Ingress** | TCP | 80, 443 | `0.0.0.0/0` | HTTP/HTTPS доступ к приложению. |
| **Ingress** | ANY | Все | `self_security_group` | Внутренний трафик между VM. |
| **Egress** | ANY | Все | `0.0.0.0/0` | Разрешение всего исходящего трафика. |

<img width="1920" height="1080" alt="Снимок экрана (1856)" src="https://github.com/user-attachments/assets/0b15cd02-e05f-4e1b-ad3e-da7118568cc4" />

### 1.2. Создание виртуальных машин (VM)

Ресурс `yandex_compute_instance` настроен с использованием минимального хардкода:

*   **Количество VM**: `count = var.vm_count` (3 VM).
*   **Тип образа**: Container Optimized Image (COI).
*   **Прерываемость**: `scheduling_policy { preemptible = true }`.
*   **Аутентификация**: Назначен `service_account_id` для работы с Container Registry.
*   **Hostname**: Установлено чистое имя (`app-server-${count.index + 1}`).

<img width="1920" height="1080" alt="Снимок экрана (1849)" src="https://github.com/user-attachments/assets/6146d4d9-9005-4fec-b0a8-24950a4b6d0e" />

### 1.3. Описание создания БД MySQL и Container Registry

| Компонент | Файл | Особенности |
| :--- | :--- | :--- |
| **MySQL Cluster** | `database.tf` | Версия 8.0, `s2.micro`, диск SSD. Созданы БД (`app_database`) и пользователь (`app_user`) с необходимыми ролями (`roles = ["ALL"]`). |
| **Container Registry** | `registry.tf` | Создан для хранения Docker-образов приложения. |

<img width="1920" height="1080" alt="Снимок экрана (1848)" src="https://github.com/user-attachments/assets/d23e68c4-d6fa-4bd2-ae55-e4c17f355235" />

## Задание 2. Используя user-data (cloud-init), установите Docker и Docker Compose (см. Задания 5 модуля «Виртуализация и контейнеризация»).

## Ответ:

### Обоснование выбора образа и метода установки

1.  **Docker Engine**: Я использовали образ **Yandex Container Optimized Image (COI)**. Docker Engine уже предустановлен в этом образе, что позволяет пропустить его ручную установку и сразу перейти к настройке.
2.  **Docker Compose**: COI не содержит `docker-compose`. Я установил его, используя команды `runcmd` в `cloud-init`.

### Код `compute.tf` (Блок `locals`)

Следующий фрагмент `cloud-init` гарантирует установку Docker Compose, настройку пользователя для работы с Docker и добавление SSH-ключа:

```hcl
locals {
  ssh_key_content = file(var.ssh_public_key_path)
  vm_metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: ${var.ssh_user}
          groups: sudo
          shell: /bin/bash
          sudo: 'ALL=(ALL) NOPASSWD:ALL'
          ssh_authorized_keys:
            - ${local.ssh_key_content}

      runcmd:
        - [ sh, -c, "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose" ]
        # 2. Установка прав на исполнение
        - [ sh, -c, "sudo chmod +x /usr/local/bin/docker-compose" ]
        # 3. Добавление пользователя в группу docker (если используем обычный образ, на COI это часто не обязательно, но безопасно)
        - [ sh, -c, "sudo usermod -aG docker ${var.ssh_user}" ]
      EOT
  }
}
```

## Задание 3. Опишите Docker файл (см. Задания 5 «Виртуализация и контейнеризация») c web-приложением и сохраните контейнер в Container Registry.

## Ответ:

### 3.1. Dockerfile (Мультисборка)

Мультистадийная сборка позволяет собрать зависимости в одном "builder" контейнере и скопировать только необходимые файлы в финальный, минималистичный образ (`python:3.9-slim`).

```Dockerfile
FROM python:3.9 AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```
### 3.2. Сохранение образа в Container Registry
После локальной сборки образа (app-final-project:v2) он был тегирован с использованием ID нового Registry (crp10qun292h5l306r4e) и отправлен в Yandex Container Registry.

Команды для отправки (выполнялись локально):

```bash
REGISTRY_ID="crp10qun292h5l306r4e"
docker tag app-final-project:v2 cr.yandex/${REGISTRY_ID}/app-final-project:v2
docker push cr.yandex/${REGISTRY_ID}/app-final-project:v2
```

<img width="1920" height="1080" alt="Снимок экрана (1858)" src="https://github.com/user-attachments/assets/92fa13bd-a0a1-45c8-8cec-0947f2c8c1ce" />

## Задание 4. Завяжите работу приложения в контейнере на БД в Yandex Cloud.

### 4.1. Механизм подключения

Приложение (`app.py`) было разработано так, чтобы читать учетные данные и адрес хоста БД из переменных окружения.

| Параметр приложения | Источник данных | Метод передачи |
| :--- | :--- | :--- |
| `DB_HOST` | FQDN первого хоста MySQL кластера (Output Terraform) | Переменная окружения `-e` при запуске Docker |
| `DB_USER` | Имя пользователя, созданное Terraform (`app_user`) | Переменная окружения `-e` |
| `DB_PASSWORD` | Пароль, взятый из `terraform.tfvars` | Переменная окружения `-e` |

### 4.2. Обеспечение сетевого доступа

Для успешного подключения необходимо было гарантировать, что трафик по порту MySQL (по умолчанию 3306) разрешен:

*   **SG Ingress Rule**: В группу безопасности `app-security-group` было добавлено правило, разрешающее входящий трафик по всем портам с **предопределенной целью `self_security_group`**. Поскольку кластер MySQL находится в той же VPC и присоединен к той же SG, это правило разрешает VM (192.168.10.x) подключаться к кластеру MySQL (192.168.10.y).

### 4.3. Команда запуска контейнера

Контейнер был запущен на VM (`51.250.90.29`), используя актуальные динамические значения, полученные из `terraform output`:

```bash
# ПЕРЕМЕННЫЕ
MYSQL_HOST="rc1a-gr8unng38btosq3r.mdb.yandexcloud.net" 
DB_PASSWORD="AppProjectSecurePwd123" 
REGISTRY_PATH="cr.yandex/crp10qun292h5l306r4e/app-final-project:v3"

# Запуск с передачей ENV переменных.
docker run -d \
  --name app-web \
  -p 80:5000 \
  -e DB_HOST="${MYSQL_HOST}" \
  -e DB_USER="app_user" \
  -e DB_PASSWORD="${DB_PASSWORD}" \
  -e DB_NAME="app_database" \
  "${REGISTRY_PATH}"
```
### 4.4. Финальное подтверждение
После запуска, приложение стало доступно по публичному IP и подтвердило успешное соединение с базой данных.

<img width="1920" height="1080" alt="Снимок экрана (1851)" src="https://github.com/user-attachments/assets/88b7122a-19a4-4b30-bb5f-26573eca3510" />

<img width="1920" height="1080" alt="Снимок экрана (1860)" src="https://github.com/user-attachments/assets/1f53fb7a-6b7a-45d3-add5-e450d345a5b7" />



